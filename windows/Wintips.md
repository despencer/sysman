# Setting language for legacy non-UTF application

Go to `Settings | Time & Language | Language & Region`, select `Windows display language | Language for non-Unicode programs` and set the language
that would be used in legacy console.

# Using legacy console
This legacy console is fast and efficient.

Open `PowerShell` in administrative mode and run the command
```
Add-WindowsCapability -Online -Name Microsoft.Windows.Console.Legacy~~~~

```
Four tildes at the end are required for not-specifying the version and accept any.

After this, one can select option `Use legacy console` in application properties.


# Adding certificates in Mozilla Firefox

Type `about:preferences` in address string.

Go to `Privacy and Security | Connection and software security | Certificates | Manage certificates`, then press `Import`.