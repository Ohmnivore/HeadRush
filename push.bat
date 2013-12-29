::"C:\Program Files (x86)\Git\bin\sh.exe" --login -i
cd "C:\Users\Ohmnivore\Desktop\AS3DEV\HeadRush"
echo Type commit message:
set /p message= ---:
"C:\Program Files (x86)\Git\bin\git.exe" add -A
"C:\Program Files (x86)\Git\bin\git.exe" commit -m "%message%"
"C:\Program Files (x86)\Git\bin\git.exe" push