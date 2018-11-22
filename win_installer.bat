@echo off
set REMOTE_IP=000.000.000.000
set SSH_PATH=C:\Program Files\AywaCore\daemon

set AYWA_DATADIR=C:\Users\user\AppData\Roaming\AywaCore
rem SSH_USER - sudo user or root with allowed ssh access used for initial setup
set SSH_USER=root
set AYWACORE_CLI_PATH=C:\Program Files\AywaCore\daemon
set /a REMOTE_PORT_START=20771
set /a REMOTE_RPCPORT_START=30771
set MN_COUNT=10
set MN_NAME_PREFIX=MN_
rem set NEW_ADDRESS=""
rem set MN_UTXO=""
rem set MN_GENKEY=""

set MN_USER=aywa
set MN_USER_PASS=

"%SSH_PATH%\ssh.exe" %SSH_USER%@%REMOTE_IP% "cd ~ && mkdir -p tmp && cd tmp && rm -f * && wget https://raw.githubusercontent.com/GetAywa/Aywa_Masternode/master/mn_prepare.sh && chmod 777 mn_prepare.sh && sudo -S ./mn_prepare.sh %MN_COUNT% %MN_USER% %MN_USER_PASS%&& rm -f mn_prepare.sh"
@echo off
echo "Wait for server reboot then press a key."
pause 120

rem generate utxo
echo "Will be created %MN_COUNT% transaction(s) for masternodes. Press Ctrl+C to break or any key to continue"

for /f "tokens=*" %%a in ('"%AYWACORE_CLI_PATH%\aywa-cli.exe" getbalance') do set CURRENT_BALANCE=%%a

echo Your current balance is: %CURRENT_BALANCE%
rem "%AYWACORE_CLI_PATH%\aywa-cli.exe" getbalance 

rem echo Current Masternode cost:
rem "%AYWACORE_CLI_PATH%\aywa-cli.exe" masternode cost

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
rem echo %MN_NAME_PREFIX%%%G %REMOTE_IP%:%REMOTE_PORT% %MN_GENKEY% %MN_UTXO% 1
)

set REMOTE_COMMAND= 
FOR /L %%G IN (1,1,%MN_COUNT%) DO (
echo Copy aywa.conf file %%G
"%SSH_PATH%\pscp.exe" -pw %MN_USER_PASS% %HOMEDRIVE%%HOMEPATH%\.tmp\%MN_NAME_PREFIX%%%Gaywa.conf %MN_USER%@%REMOTE_IP%:/home/%MN_USER%/.masternodes/node%%G/aywa.conf
rem "%SSH_PATH%\putty.exe" %SSH_USER%@%REMOTE_IP%
set REMOTE_COMMAND=(%REMOTE_COMMAND%)""(crontab -l; echo "@reboot echo "rebooted%%G"";) | crontab - &&""
)

echo %REMOTE_COMMAND%


EXIT /B %ERRORLEVEL%

:create_tx
@echo off
for /f "tokens=*" %%a in ('"%AYWACORE_CLI_PATH%\aywa-cli.exe" getnewaddress %MN_NAME_PREFIX%%%G') do set NEW_ADDRESS=%%a
echo Created new address: %NEW_ADDRESS%
for /f "tokens=*" %%b in ('"%AYWACORE_CLI_PATH%\aywa-cli.exe" sendtoaddress %NEW_ADDRESS% %MASTERNODE_COST%') do set MN_UTXO=%%b
echo Created MN UTXO id (collateral_output_txid):%MN_UTXO%
for /f "tokens=*" %%c in ('"%AYWACORE_CLI_PATH%\aywa-cli.exe" masternode genkey') do set MN_GENKEY=%%c
echo Generated MN key (masternodeprivkey):%MN_GENKEY%


echo Adding line to %AYWA_DATADIR%\masternode.conf: %MN_NAME_PREFIX%%COUNTER% %REMOTE_IP%:%REMOTE_PORT% %MN_GENKEY% %MN_UTXO% 1

echo %MN_NAME_PREFIX%%COUNTER% %REMOTE_IP%:%REMOTE_PORT% %MN_GENKEY% %MN_UTXO% 1 >>%AYWA_DATADIR%\masternode.conf


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
echo masternodeaddr=%REMOTE_IP%:%REMOTE_PORT%
)>%MN_NAME_PREFIX%%COUNTER%aywa.conf


set /a REMOTE_PORT=%REMOTE_PORT%+1
set /a REMOTE_RPC_PORT=%REMOTE_RPC_PORT%+1
