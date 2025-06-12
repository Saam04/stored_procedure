@echo off
sqlcmd -S localhost -d AdventureWorks2012 -E -i "C:\sqlbackups\reorg_index.sql" >> "C:\sqlbackups\reorg_log.txt"
echo %date% %time% - Reorganization script executed. >> "C:\sqlbackups\reorg_log.txt"
