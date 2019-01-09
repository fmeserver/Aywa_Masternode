Check aywad running status

If the file is not ~/aywa/aywad, edit auto_check_aywa.sh

1.
mkdir qshell logs

2.
cd qshell

wget -c https://github.com/GetAywa/Aywa_Masternode/auto_check_aywa.sh

3.
chmod u+x auto_check_aywa.sh

3.
touch logs/aywa.check.log

4.
crontab -e

Add the following line at the end of the file.

*/30 * * * * ~/qshell/./auto_check_aywa.sh >> ~/logs/aywa.check.log 

Ctrl+O to save, and Ctrl+X to exit the nano editor.
