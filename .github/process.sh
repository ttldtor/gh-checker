#!/bin/sh

config=$1

for repo_record in $(cat ${config} | jq -c '.[]'); do
    repo_type=$(echo "${repo_record}" | jq -r '.type')
    repo_user=$(echo "${repo_record}" | jq -r '.user')
    
    repo=$(echo "${repo_record}" | jq -r '.repo')
    branch=$(echo "${repo_record}" | jq -r '.branch')
    path=""

    if [ "$repo_type" = "github" ]; then
        path="https://raw.githubusercontent.com/${repo_user}/${repo}/${branch}"
    elif [ "$repo_type" = "gitlab" ]; then
        path="https://gitlab.com/${repo_user}/${repo}/-/raw/${branch}"
    elif [ "$repo_type" = "bitbucket" ]; then
        path="https://bitbucket.org/${repo_user}/${repo}/raw/${branch}"
    else
        path="$repo"
    fi

    for file_record in $(echo "${repo_record}" | jq -c '.files | .[]'); do
        file=$(echo ${file_record} | jq -r '.path')
        last_hash=$(echo ${file_record} | jq -r '.lastHash')
        file_path="${path}/${file}"
        new_hash="$(curl -sL $file_path | md5sum | cut -d ' ' -f 1)"
        echo hash: ${last_hash}, file: ${file_path}
        echo new hash: ${new_hash}
    done
done
