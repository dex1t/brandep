#brandep

Githubにpushされた際に、hookされるSinatraアプリ  
WebHook URLsにて、このアプリのURLを指定してね  
***

- Githubにpushされたブランチを,指定ディレクトリにデプロイ(clone)する
- 既にcloneされていた場合は,git pull
- Github上のリモートブランチを削除した場合は,指定ディレクトリからも削除
- デプロイ時に外部スクリプトを呼び出す
