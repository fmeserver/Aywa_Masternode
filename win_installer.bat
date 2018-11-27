@echo off
set REMOTE_IP=000.000.000.000
set EXTERNAL_IP=000.000.000.000
set SSH_PATH=C:\Program Files\AywaCore\daemon

set AYWA_DATADIR=C:\Users\user\AppData\Roaming\AywaCore
rem SSH_USER - sudo user or root with allowed ssh access used for initial setup

set SSH_USER=user
set AYWACORE_CLI_PATH=C:\Program Files\AywaCore\daemon
set /a REMOTE_PORT_START=20771
set /a REMOTE_RPCPORT_START=30771
set MN_COUNT=10
set MN_NAME_PREFIX=MN1__
rem set NEW_ADDRESS=""
rem set MN_UTXO=""
rem set MN_GENKEY=""

set MN_USER=user
set MN_USER_PASS=yourpasshere

"%SSH_PATH%\ssh.exe" %SSH_USER%@%REMOTE_IP% "cd ~ && mkdir -p tmp && cd tmp && rm -f * && wget https://raw.githubusercontent.com/GetAywa/Aywa_Masternode/master/mn_prepare.sh && chmod 777 mn_prepare.sh && sudo -S ./mn_prepare.sh %MN_COUNT% %MN_USER% %MN_USER_PASS%&& rm -f mn_prepare.sh"
@echo off
echo "Wait for server reboot then press a key."
pause 120

rem ****************generate utxo***********************
echo "Will be created %MN_COUNT% transaction(s) for masternodes. Press Ctrl+C to break or any key to continue"

for /f "tokens=*" %%a in ('"%AYWACORE_CLI_PATH%\aywa-cli.exe" getbalance') do set CURRENT_BALANCE=%%a

echo Your current balance is: %CURRENT_BALANCE%

for /f "tokens=*" %%a in ('"%AYWACORE_CLI_PATH%\aywa-cli.exe" masternode cost') do set MASTERNODE_COST=%%a

echo Current Masternode cost: %MASTERNODE_COST%
@echo off
%HOMEDRIVE% && cd %HOMEPATH%
mkdir .tmp
cd .tmp
set /a REMOTE_PORT=%REMOTE_PORT_START%
set /a REMOTE_RPC_PORT=%REMOTE_RPCPORT_START%
set /a MN_COUNT=%MN_COUNT%
FOR /L %%G IN (1,1,%MN_COUNT%) DO (
rem echo Creating MN UTXO %%G
SET COUNTER=%%G
@echo off
call:create_tx
)

rem set REMOTE_COMMAND= 
echo wil be copied conf files to remote server
pause 0
FOR /L %%G IN (1,1,%MN_COUNT%) DO (
echo Copy aywa.conf file %%G
"%SSH_PATH%\pscp.exe" -pw %MN_USER_PASS% %HOMEDRIVE%%HOMEPATH%\.tmp\%MN_NAME_PREFIX%%%Gaywa.conf %MN_USER%@%REMOTE_IP%:/home/%MN_USER%/.masternodes/node%%G/aywa.conf
rem "%SSH_PATH%\putty.exe" %SSH_USER%@%REMOTE_IP%
rem set REMOTE_COMMAND=(%REMOTE_COMMAND%)""(crontab -l; echo "@reboot echo "rebooted%%G"";) | crontab - &&""
)

echo %REMOTE_COMMAND%


rem ********************************************************
echo Now start 1 (only one - first) wallet ann allow it to sync to the last block
echo (You can copy blocks from any of your server: rsvnc -avz ~/.aywacore/blocks ~/.aywacore/chainstate user@192.168.1.68:~/.masternodes/node1)
echo establish ssh connection with you server 
echo Command to start: /home/user/aywacore/bin/aywad -datadir=/home/user/.masternodes/node1
pause 0

echo After sync stop wallet and copy ~/.masternodes/node1/chainstate ~/.masternodes/node1/blocks to ~/.masternodes/node$COUNTER

rem here is command

echo Wait full sync. Ctrl+C to continue and copy blockchain data

wait /home/user/aywacore/bin/aywa-cli -datadir=/home/user/.masternodes/node1 getinfo

pause 0
for i in {2..%MN_COUNT%}; do echo "Node $i"  && cp -vr /home/user/.masternodes/node1/chainstate /home/user/.masternodes/node1/blocks /home/user/.masternodes/node$i; done

rem if node doesnt have public IP
set /a REMOTE_PORT_END=%REMOTE_PORT_START%+%MN_COUNT%
#sudo iptables -t nat -I OUTPUT -d %EXTERNAL_IP% -p tcp  -j REDIRECT --to-ports %REMOTE_PORT_START%-%REMOTE_PORT_END%
rem sudo crontab -e
rem example: sudo iptables -t nat -I OUTPUT -d 193.218.143.171 -p tcp  -j REDIRECT --to-ports 20771-20870

rem start 10 wallets
#for i in {1..50}; do echo "Node $i starting"  && /home/user/aywacore/bin/aywad -datadir=/home/user/.masternodes/node$i; done; 

rem check status
#for i in {1..10}; do echo "Node $i info:"  && /home/user/aywacore/bin/aywa-cli -datadir=/home/user/.masternodes/node$i getinfo; done;

rem wait until wallets sync ang has at least 5 connections

rem start 10 MNs
rem add logs folder 
mkdir /home/user/.masternodes/logs

rem add crontab -e
rem ***************
rem * * * * * cd /home/user/.masternodes/node1/sentinel && SENTINEL_DEBUG=1 /home/user/Aywa_Masternode/sentinel/.venv/bin/python bin/sentinel.py > /home/user/.masternodes/logs/sentinel1.log
rem @reboot /home/user/aywacore/bin/aywad -datadir=/home/user/.masternodes/node1> /home/user/.masternodes/logs/start_aywad1.log
rem *****************************************

rem start MNs from local wallet
rem if ENABLE status for 1-10 Mns

rem start next ones
rem copy data
#for i in {11..100}; do echo "Node $i"  && cp -vr /home/user/.masternodes/node1/chainstate /home/user/.masternodes/node1/blocks /home/user/.masternodes/node$i; done
rem start it
for i in {11..100}; do echo "Node $i starting"  && /home/user/aywacore/bin/aywad -datadir=/home/user/.masternodes/node$i; done;


EXIT /B %ERRORLEVEL%

:create_tx
@echo off
for /f "tokens=*" %%a in ('"%AYWACORE_CLI_PATH%\aywa-cli.exe" getnewaddress %MN_NAME_PREFIX%%COUNTER%') do set NEW_ADDRESS=%%a
echo Created new address: %NEW_ADDRESS%
for /f "tokens=*" %%b in ('"%AYWACORE_CLI_PATH%\aywa-cli.exe" sendtoaddress %NEW_ADDRESS% %MASTERNODE_COST%') do set MN_UTXO=%%b
echo Created MN UTXO id (collateral_output_txid):%MN_UTXO%
for /f "tokens=*" %%c in ('"%AYWACORE_CLI_PATH%\aywa-cli.exe" masternode genkey') do set MN_GENKEY=%%c
echo Generated MN key (masternodeprivkey):%MN_GENKEY%
							  
rem for /f "tokens=*" %%d in ('""%AYWACORE_CLI_PATH%\aywa-cli.exe" lockunspent false"[{\"txid\":\"%MN_UTXO%\" ","\"vout\":%MASTERNODE_COST%}]""') do set MN_UTXO_LOCKRESULT=%%d

for /f "tokens=*" %%d in ('""%AYWACORE_CLI_PATH%\aywa-cli.exe" lockunspent false "[{\"txid\":\"%MN_UTXO%\" ","\"vout\":1}]""') do set MN_UTXO_LOCKRESULT=%%d

echo UTXO %MN_UTXO% lock result: %MN_UTXO_LOCKRESULT%
rem pause 0
echo Adding line to %AYWA_DATADIR%\masternode.conf: %MN_NAME_PREFIX%%COUNTER% %REMOTE_IP%:%REMOTE_PORT% %MN_GENKEY% %MN_UTXO% 1

echo %MN_NAME_PREFIX%%COUNTER% %EXTERNAL_IP%:%REMOTE_PORT% %MN_GENKEY% %MN_UTXO% 1 >>%AYWA_DATADIR%\masternode.conf
(
echo rpcuser=aywauser%RANDOM%%RANDOM%%RANDOM%%RANDOM%%RANDOM%
echo rpcpassword=rpcpass%RANDOM%%RANDOM%%RANDOM%%RANDOM%%RANDOM%%RANDOM%%RANDOM%%RANDOM%%RANDOM%%RANDOM%%RANDOM%
echo rpcallowip=127.0.0.1
echo listen=1
echo server=1
echo daemon=1
echo smsgdisable=1
echo port=%REMOTE_PORT%
echo rpcport=%REMOTE_RPC_PORT%
echo masternode=1
echo masternodeprivkey=%MN_GENKEY%
echo masternodeaddr=%EXTERNAL_IP%:%REMOTE_PORT%
echo externalip=%EXTERNAL_IP%
)>%MN_NAME_PREFIX%%COUNTER%aywa.conf


set /a REMOTE_PORT=%REMOTE_PORT%+1
set /a REMOTE_RPC_PORT=%REMOTE_RPC_PORT%+1
