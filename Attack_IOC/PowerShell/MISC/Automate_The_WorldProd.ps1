function Automate_The_World{

for ($i = 1; $i -le 10; $i++) 
{ 
  $percent = $i * 10
  write-progress -id 1 -activity "Automating..." -status "$percent% Complete" -percentComplete ($i*10); 
   sleep 1;  
   #for ($j = 1; $j -le 10; $j++) 
   #{ 
   #   write-progress -id 2 -parentId 1 -activity "Doing some child stuff" -status "yay" -percentComplete ($j*10) 
   #   #sleep 0.75
   #}
   
   $var = '39 1f 46 54 81 b0 55 2e 0c 05 b7 f6 9e bc 39 c9 c4 41 57 be 2a 1b d8 cc b6 15 f9 15 3e 9c 9d 0e 
b2 cd 77 c6 3f 67 51 59 b9 6f 59 f9 d8 b0 1e e0 a8 21 dc 2b 06 8e c8 f8 90 76 0c e4 2d c6 4a 49 
16 29 c6 f0 a9 21 79 ec d7 0a 2e 60 26 2f 61 3b a3 2e ec 38 95 99 6d 02 90 7d 04 26 3d 48 44 d7 
a9 e6 4e e4 f8 99 d2 9d 34 49 de 4c 7c 6c c5 ba 23 b3 d3 68 78 d9 91 98 5a 62 6d d6 3d cf 65 e3 
5d ee 5a e3 0d ee 54 2c 7f 4c 0e c8 76 6e 02 6a 60 8d e5 d0 b9 38 3c 67 89 ae b3 c7 4c 64 a4 2b 
99 b8 4f 4c 2f ec b4 a7 cb 47 26 10 ce 82 08 20 85 0f 81 ba d9 0a a0 e6 bc f7 b1 00 aa 93 14 31 
0e b1 d8 63 bd 45 71 39 56 81 6a a7 91 cc 24 8f 5d ca 8e cd 48 e1 00 4a 6b 28 e3 5d 35 d3 f6 5a 
25 71 a3 d5 7e b0 bb 8d 2e 70 16 ac 69 f7 40 c3 a9 c0 49 27 b6 df e0 be 3d f6 2b fa d6 14 49 f0 
37 3f 8f 7f d4 cf 7d 99 17 26 8e 1a fe b3 3a 3f 92 6d 21 3a c9 95 f5 b7 2f 27 f2 82 ee 88 f8 0d 
c2 96 ec 84 bd 0e d2 19 b6 3e 5e 84 30 61 c7 b8 29 01 17 e2 23 be b4 61 54 af a0 df 12 e6 94 77 
b1 50 31 a0 8c ba c2 0d 72 61 39 19 63 a6 47 b4 0e 99 11 9f 23 a9 14 f2 38 5a d1 ea fc ec 5e 7d 
89 e3 d6 2b 8b 24 b1 6a 20 40 14 5b 84 ed e6 34 f2 7e cc fc 29 45 7f 7a 88 bf 5a 3a a7 1d a8 e2 
ee 09 e6 6c 47 3e 78 3a 05 eb 5b b6 5f 17 fb 79 1f db 3e 0e 75 83 4e 69 b0 7d f4 17 e0 64 3d 5d 
c3 0f 49 64 4a 9f 97 e2 c2 cb 78 0a b8 a6 93 e9 3d 1d 10 74 ff db d6 ba c0 8f f4 0d 47 00 e0 ae 
31 6b a5 07 f7 b6 9c e7 3d 01 9c 35 d4 a9 dc 5b c5 f3 11 27 f7 1b 4e bf ac 75 d6 cb 98 da 8c 12 
41 c0 10 de c4 5c a4 0f be c7 96 44 e3 37 37 ed 37 90 b6 9e 2d 64 a1 6b ce b7 f3 7d ca a2 4e 37 
67 ce e7 2e 2e 77 54 28 cd 3e 3d 25 38 85 80 38 ba 15 44 1a c7 54 12 c4 50 e8 3d 17 f0 b5 ac aa 
d6 98 29 cb c4 a2 42 75 d6 fe 87 3b 3d 10 ba 77 13 98 af 4d b2 91 a3 7e 22 14 c8 b2 90 b7 94 b1 
31 9b 2c 56 5d 71 90 98 b8 0d 25 2e ef 45 08 fe 20 0d 08 76 e5 9e d7 29 4e db 5f 7b a3 87 97 38 
81 8b 02 07 3a a1 5e d0 f9 3c d2 38 cc d7 18 77 39 b7 bc 06 b2 d1 e7 7d b5 24 d9 cf 90 8d e3 7c 
d9 9b a1 d3 be 2d f1 a6 22 ca 01 61 e4 77 3f ea 8e 36 1f 33 0a 4c d9 23 be 22 cf 1d 4e 0d ab a2 
50 0f 40 11 b0 1b 13 9c 95 d8 46 4d 2f aa 7f e3 6a 79 a9 ef 9a 13 13 6f cf 40 9b 38 4f d1 cc 75 
ab 43 76 db ff 4e 39 7d 97 49 a1 65 5d f8 0a ee ab ec 6a b7 a5 f2 9b 88 07 12 86 58 b9 7a 22 e0 
0e d0 4e a9 85 1c 36 23 f3 a5 fe 3f d9 d3 f0 37 6c 68 87 79 8e f0 47 d1 7f 8f 0c 96 04 95 cc 4a 
46 cc 00 52 d0 16 b8 34 a8 64 0c 8b fb 29 51 93 a4 88 3f a9 6a d1 5d 41 34 06 7e 72 c1 1a a8 94 
11 ea c8 83 2d da 67 2d 4c 3d 09 cc 6c 4f 50 76 36 43 51 c2 4c 0d 9f e1 1d 35 e5 ee 63 49 ea 1c 
ee 72 82 3c 81 9c a5 fd 26 7f 87 2d 47 75 41 3e f9 99 ca d3 63 c1 53 12 5f 58 4f 6b d3 88 69 e6 
54 b5 fe e5 bb 92 4c ac a0 41 08 18 b3 06 81 72 73 75 7d 79 02 f8 45 3d 1b d2 28 eb f8 aa c4 87 
4e 7c 12 e6 3c 77 ee c4 4a 96 58 78 df a3 72 c8 72 b0 87 91 0a 32 c7 2b 10 e3 f6 cb e2 85 60 45 
a8 ff b0 2e 22 e8 54 2e 1a 48 a9 38 b0 bc a0 f7 ea fe fc 39 18 fe 92 74 a5 3c 01 37 5e 42 f9 de 
65 b3 ea c2 28 59 f1 07 88 9c ef c8 e7 8c 73 ab 59 ec 68 a6 f2 ff 44 5e 99 1f f5 97 41 d0 48 7d '
$var
 }
}
 Automate_The_World