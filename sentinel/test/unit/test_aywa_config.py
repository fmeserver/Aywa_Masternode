import pytest
import os
import sys
import re
os.environ['SENTINEL_CONFIG'] = os.path.normpath(os.path.join(os.path.dirname(__file__), '../test_sentinel.conf'))
os.environ['SENTINEL_ENV'] = 'test'
sys.path.append(os.path.normpath(os.path.join(os.path.dirname(__file__), '../../lib')))
import config
from aywa_config import AywaConfig


@pytest.fixture
def aywa_conf(**kwargs):
    defaults = {
        'rpcuser': 'yourrpcusername',
        'rpcpassword': 'yourlongrpcpassword',
        'rpcport': 2778,
    }

    # merge kwargs into defaults
    for (key, value) in kwargs.items():
        defaults[key] = value

    conf = """# basic settings
testnet=1 # TESTNET
server=1
rpcuser={rpcuser}
rpcpassword={rpcpassword}
rpcallowip=127.0.0.1
rpcport={rpcport}
""".format(**defaults)

    return conf


def test_get_rpc_creds():
    aywa_config = aywa_conf()
    creds = AywaConfig.get_rpc_creds(aywa_config, 'testnet')

    for key in ('user', 'password', 'port'):
        assert key in creds
    assert creds.get('user') == 'yourrpcusername'
    assert creds.get('password') == 'yourlongrpcpassword'
    assert creds.get('port') == 2778

    aywa_config = aywa_conf(rpcpassword='yourlongrpcpassword', rpcport=2778)
    creds = AywaConfig.get_rpc_creds(aywa_config, 'testnet')

    for key in ('user', 'password', 'port'):
        assert key in creds
    assert creds.get('user') == 'yourrpcusername'
    assert creds.get('password') == 'yourlongrpcpassword'
    assert creds.get('port') == 2778

    no_port_specified = re.sub('\nrpcport=.*?\n', '\n', aywa_conf(), re.M)
    creds = AywaConfig.get_rpc_creds(no_port_specified, 'testnet')

    for key in ('user', 'password', 'port'):
        assert key in creds
    assert creds.get('user') == 'yourrpcusername'
    assert creds.get('password') == 'yourlongrpcpassword'
    assert creds.get('port') == 27780


# ensure aywa network (mainnet, testnet) matches that specified in config
# requires running aywad on whatever port specified...
#
# This is more of a aywad/jsonrpc test than a config test...
