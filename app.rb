require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require 'yaml'
require 'logger'

begin
  @@conf = YAML::load open(File.dirname(__FILE__)+'/config.yaml').read
  @@conf['deploy_dir'] += "/" if @@conf['deploy_dir'][-1] != "/"
rescue => e
  STDERR.puts 'config.yaml load error!'
  STDERR.puts e
  exit 1
end
log = Logger.new('public/hook.log', 'daily')

def git_clone(ssh, path, branch)
  system "git clone #{ssh} #{path} -b #{branch}"
  system "#{@@conf['deploy_script']} #{path} #{branch.gsub('/','_')}" #外部スクリプト実行
end

def git_pull(path)
  Dir.chdir(path){
    system "git pull"
  }
end

post '/' do
    return 403 if params[:key] != @@conf["api_key"]
    push = JSON.parse(params[:payload])

    ssh = push['repository']['url'].sub("https://github.com/", "git@github.com:") #公開鍵認証するため
    branch = push['ref'].slice(11..-1) #refs/heads/以降がブランチ名
    target_path = @@conf["deploy_dir"] + branch.gsub("/","_")

    log.debug "before:#{push['before']} after:#{push['after']}"
    log.info "ssh: #{ssh} branch: #{branch} / target_path: #{target_path}"

    if push['before'] == "0"*40 #branchが始めてリモートにpush
      git_clone(ssh, target_path, branch)
    elsif push['after'] == "0"*40 #branchがリモートから削除
      system "rm -rf #{target_path}" if File.exists?(target_path)
    else
      if File.exists?(target_path)
        git_pull(target_path)
      else
        git_clone(ssh, target_path, branch)
      end
    end

    log.info 'current state:'+`ls #{@@conf['deploy_dir'][0..-2]}`
end
