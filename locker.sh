exec xautolock -detectsleep -time 10 -locker "dm-tool lock" -notify 30 -notifier "notify-send -u critical -t 3000 -- 'LOCKING screen in 30 seconds'"
