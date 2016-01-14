# from_tse_to_coo

A bunch of quick and dirty scripts

This is tested on my Fedora 22, and I make no guarantees whether I will port to a different flavor or not.

## cgroups
limit.io - wrapper for limiting bandwidth using blkio controller

In this example you can see that sudo password is asked once:

```
$> ./limit.io 300000 dd if=/dev/zero of=~/dd bs=5M count=1 oflag=direct
[sudo] password for gfigueir: 
253:1 300000
253:1 300000
1+0 records in
1+0 records out
5242880 bytes (5.2 MB) copied, 17.4814 s, 300 kB/s

```

`dd` will only be throttled if oflag=direct is used.

Since it is a wrapper, you can run it with sudo with no problems:

```
./limit.io 2000000 sudo sosreport --batch 
```

During sosreport's read part, note that bi is often bellow 2000
```
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 1  2 587072  14816  27640 1145460    0   38  2078    50  648 1078  3  1 24 72
0
 0  2 587072  15116  27072 1145184    0    0  2053     3  633  649  1  0 21 77
0
 0  2 587072  14968  27088 1147048    0    0  2042   202  581 1143  2  1  8 89
0
 1  2 587072  16192  27088 1144944    0    0  2040     1  689 1312  2  1  2 94
0
 0  2 587072  14912  27092 1146612    0    0  1864     2  493  619  2  1  7 91
0
 0  2 587072  17756  27100 1143596    0    0  2047     4  285  555  1  0 46 53
0
 0  2 587072  19376  27100 1141976    0    0  2056     0  259  472  0  0 32 67
0
 0  2 587072  17652  27100 1143768    0    0  2057     0  226  407  0  0 50 49
0
 0  2 587080  16272  27100 1145296    0    0  2060     0  226  398  0  0 46 54
0
 0  2 587600  18112  27504 1144092    0  104  1791   105  506  831  5  2 47 46
0
 0  2 589128  16684  27568 1124856    0  382  1910   447  682 1235  4  2 37 58
0
 0  2 589716  20144  27456 1122392    0  149  2022   158  390  583  1  1  3 94
0
 1  2 591792  38516  27472 1080320    0  375  2018   440  381  469  2  2  1 95
0
```
