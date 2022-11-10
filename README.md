# VMware-SSL-VPN-Plus-Removal


VMware SSL VPN-Pro silent untinstaller to be able to run it via intume or else.

Why?
The Application is specific therefore does not use msi.
its uninstaller cannot run silently in the background, it need user intervention to 'answer' question.
Therefore you cannot use it via intune or esle to silently remove the software.

I could not find anything onto the web, therefore I decided to give it a go.

It is a powershell script
It is pretty basic.
It is not 'a one liner' as some 'genius' would do.
The reasons are simple:
            Easy to degug when I wrote it.
            Easy to read in few months time.
            Esay to reuse the code or part of it.
            It does the job anyway.
            
I had to run some 'steps' before others to uninstall properly
I had to check the running version of powershell since some commands do not exist in older version.

I can run the script silently.
If I want to reinstall the Apps, a reboot will be needed.

I have tested manually in a intune 'VM'.
when done I rebooted the VM and after a while the Apps was reinstall since setup in intume

the next step is to upload the script to intune
create a group, let say 'VMwareSSLvpnRemoval'
link the untinstaller (the script) to it
add a test computer and wait.
The reboot will not be needed since we do not plan to reuse it.
