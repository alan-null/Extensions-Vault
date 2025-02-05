# Extensions Vault
<img align="left" width="30%" src="https://gist.githubusercontent.com/alan-null/5126c04ebff9a7f6bf983e2dfa18813b/raw/0de1d69947a827fd1b77e9a0b8bac02598581263/stealthy-tin-foil-hooded-cat-inspired-by-mr.robot.png" style="margin-right:5px" >

> [!IMPORTANT]
> ### I don't trust third parties and their security processes.

This is my private database of Chrome extensions.
You might find this idea extreme or unusual —

**BUT**

I want 100% control over the extensions I use:

###### - Know when an extension was updated and decide how to handle it.
###### - Review new code before it is loaded by my browser.

<!-- <br clear="left" /> -->


## Motivation
There are various reasons why extensions end up in this database.

### Past Events
Some are due to past experiences:

- Extensions no longer available on the Chrome Web Store.
- Newer versions
  -  Introduced features I’m not interested in.
  -  Went in a direction that conflicts with my personal beliefs.
  -  Requested excessive access rights.
- Added telemetry or analytics without proper transparency.

### Future Concerns
Others are based on potential risks I want to avoid:
- Becoming a victim of an extension owner's decision to:
  - Monetize the extension by selling it.
  - Introduce malicious scripts from third-party buyers.

- being a victim of security breaches resulting malicious scripts being injected into the extension code, see [*Cyberhaven’s Chrome extension security incident*](https://www.cyberhaven.com/blog/cyberhavens-chrome-extension-security-incident-and-what-were-doing-about-it)

### Extra benefits
- **Offline installation:** no reliance on online stores.
- **No Google Account requirement:** use extensions without needing to sign in.
- **Backup:** safeguard open-source extensions not distributed through the Chrome Web Store.

## Project Structure

###  📁db
Contains approved extensions. There are two types of files:

**`crx`** - contains native Chrome extension package. Unmodified store package with correct signatures inside.

**`zip`** - contains updated extension build based on source code or `crx`.

  Additional information can be found in `README.md` files in each catalog.

### 📁out
Initially empty. Running `out.ps1` will unpack the most recent version of the extensions into this folder.

```
Extracting geddoclleiomckbhadiaipdggiiccfje-1.4.12.crx
        Deploying geddoclleiomckbhadiaipdggiiccfje-1.4.12.crx as'Quick Javascript Switcher'
        Removing existing folder
        Moving files to C:\vault\out\Quick Javascript Switcher
Extracting ompiailgknfdndiefoaoiligalphfdae-2.8.1.crx
        Deploying ompiailgknfdndiefoaoiligalphfdae-2.8.1.crx as'chromeIPass'
        Removing existing folder
        Moving files to C:\vault\out\chromeIPass
```

## How it works

1. Run **out.ps1** - script will unpack latest version of each extension from the `db` into the `out` folder.
3. Open any Chromium-based browser
4. Navigate to `chrome://extensions`
5. Enable **Developer mode**
6. Click **Load unpacked** and select the extensions one by one from the `out` folder.
    ```
    ├──📁 db
    └──📁 out
        ├──📁 chromeIPass
        └──📁 Quick Javascript Switcher
    ```

---
🛡 **Only extensions which have passed security check land here**