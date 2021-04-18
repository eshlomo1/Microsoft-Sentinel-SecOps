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
   }
 }
 Automate_The_World