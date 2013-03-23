#!/bin/bash

for i in any a aaaa afsdb apl caa cert cname dhcid dlv dname dnskey ds hip ipseckey key kx loc mx naptr ns nsec nsec3 nsec3param ptr rrsig rp sig soa spf srv sshfp ta tkey tlsa tsig txt axfr ixfr opt
do 
  echo $i
  label="$(echo $i | tr [a-z] [A-Z])"
  convert -background transparent -fill '#666666' -size 128x128 -gravity center label:$label $i.png
done 

