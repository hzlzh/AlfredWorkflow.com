#!/bin/bash

echo '<?xml version="1.0"?>'
echo '<items>'

if [[ -z "$*" || ! "$*" =~ ^.*\ $ && ! "$*" =~ ^.*\ (any|a|aaaa|afsdb|apl|caa|cert|cname|dhcid|dlv|dname|dnskey|ds|hip|ipseckey|key|kx|loc|mx|naptr|ns|nsec|nsec3|nsec3param|ptr|rrsig|rp|sig|soa|spf|srv|sshfp|ta|tkey|tlsa|tsig|txt|axfr|ixfr|opt)$ ]]
then

  echo "<item uid='dig_keep_typing' valid='no'><title>Keep typing…</title><subtitle>End your query with a space to initiate lookup. Optionally append a type such as 'mx'.</subtitle><icon>icon.png</icon></item>"

else

  read qdomain qtype <<< $*
  [[ -z "$qtype" ]] && qtype=a

  dig_opts=''
  if [[ "$qdomain" =~ ^([0-9\.]+|[0-9a-fA-F:]+)$ ]]
  then
    dig_opts="-x"
    qtype="ptr"
  fi

  while read line
  do  
    answers_found='yes'
    # pjkh.com.   751 IN  A 74.207.251.140
    # pjkh.com.   683 IN  MX  10 mx2.emailsrvr.com.
    read question ttl class atype adata answer <<< $line

    if [[ -z "$answer" ]] 
    then
      answer=${adata%.}
      title=$answer
    else
      answer=${answer%.}
      title="$adata $answer"
    fi

    if [[ -e "icons/$atype.png" ]] 
    then
      icon="icons/$atype.png"
      subtitle="$question TTL=$ttl"
    else
      icon=""
      subtitle="$atype $question TTL=$ttl"
    fi


    echo "<item uid='dig_answer' arg='$answer' valid='yes'><title>$title</title><subtitle>$subtitle</subtitle><icon>$icon</icon></item>"

  done < <(dig $dig_opts $qdomain $qtype | sed -e '1,/^;; ANSWER SECTION/d' -e '/^$/,$d')

  if [[ -z "$answers_found" ]]
  then
    echo "<item uid='dig_no_results' valid='no'><title>No Results</title><subtitle>No results found querying for $qdomain, type $qtype.</subtitle><icon>icon.png</icon></item>"
  fi

fi

echo '</items>'
