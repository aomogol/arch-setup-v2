#!/bin/bash


yay -S --needed --noconfirm dnsdiag 

#alias olarak eklenebilir
#alias dnshiz='dnseval -t A -f serverList.txt -c10 google.com'


dnseval -t A -f serverList.txt -c10 google.com