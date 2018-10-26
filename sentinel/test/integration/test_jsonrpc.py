import pytest
import sys
import os
import re
os.environ['SENTINEL_ENV'] = 'test'
os.environ['SENTINEL_CONFIG'] = os.path.normpath(os.path.join(os.path.dirname(__file__), '../test_sentinel.conf'))
sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'lib'))
sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..'))
import config

from aywad import AywaDaemon
from aywa_config import AywaConfig


def test_aywad():
    config_text = AywaConfig.slurp_config_file(config.aywa_conf)
    network = 'mainnet'
    is_testnet = False
    genesis_hash = u'00000cd0dfc9fb1939f2b94723f9cbbaeb6e76536fb612840f2097a7e73e5fa9'
    for line in config_text.split("\n"):
        if line.startswith('testnet=1'):
            network = 'testnet'
            is_testnet = True
            genesis_hash = u'00000bafbc94add76cb75e2ec92894837288a481e5c005f6563d91623bf8bc2c'

    creds = AywaConfig.get_rpc_creds(config_text, network)
    aywad = AywaDaemon(**creds)
    assert aywad.rpc_command is not None

    assert hasattr(aywad, 'rpc_connection')

    # Aywa testnet block 0 hash == 00000bafbc94add76cb75e2ec92894837288a481e5c005f6563d91623bf8bc2c
    # test commands without arguments
    info = aywad.rpc_command('getinfo')
    info_keys = [
        'blocks',
        'connections',
        'difficulty',
        'errors',
        'protocolversion',
        'proxy',
        'testnet',
        'timeoffset',
        'version',
    ]
    for key in info_keys:
        assert key in info
    assert info['testnet'] is is_testnet

    # test commands with args
    assert aywad.rpc_command('getblockhash', 0) == genesis_hash
