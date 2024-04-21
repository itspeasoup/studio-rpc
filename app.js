const DiscordRPC = require('discord-rpc');
const express = require('express');
const bodyParser = require('body-parser');

// discord application ID - replace with your own
const clientId = '1050805097036263455';

const app = express();
const port = 52;

// initialize Discord RPC
DiscordRPC.register(clientId);
const rpcClient = new DiscordRPC.Client({ transport: 'ipc' });

// middleware for parsing JSON in request body
app.use(bodyParser.json());

// start the RPC client and set the presence when connected
function login() {
  rpcClient.login({ clientId }).then(() => {
    console.log(`Logged in as ${rpcClient.user.username}`);
    updatePresence();
  }).catch((error) => {
    console.error('Error connecting to Discord:', error.message);
    console.log('(is discord even open by any chance?)');

    // retry login after a delay (e.g., 5 seconds)
    setTimeout(login, 2500);
  });
}

// start the initial login attempt
login();


// update the presence based on the data received from /change endpoint
app.post('/change', (req, res) => {
  const { details, state, largeImageKey, largeImageText, smallImageKey, smallImageText, startTimestamp} = req.body;
  
  rpcClient.setActivity({
    details: details,
    state: state,
    largeImageKey: largeImageKey,
    largeImageText: largeImageText,
    smallImageKey: smallImageKey,
    smallImageText: smallImageText,
    startTimestamp: startTimestamp
  });

  res.json({ status: 'success' });
});

// disable the presence when hitting /disable endpoint
app.get('/disable', (req, res) => {
  rpcClient.clearActivity();
  res.json({ status: 'disabled' });
});

// start the Express server
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});

// function to update presence
function updatePresence() {
  rpcClient.setActivity({
    details: "roblox studio not open",
    state: "or in menu",
    largeImageKey: "https://i.imgur.com/u10wOZC.png",
    smallImageKey: "https://i.imgur.com/KtpKh0w.png",
    smallImageText: "studio-rpc by peasoup",
  });
}

const { exec } = require('child_process');

const processName = 'RobloxStudioBeta.exe'; // replace with the process you want to monitor

const checkProcess = () => {
  exec('tasklist', (err, stdout) => {
    if (err) {
      console.error('Error checking processes:', err);
      return;
    }

    const isProcessRunning = stdout.toLowerCase().includes(processName.toLowerCase());

    if (!isProcessRunning) {
      process.exit()
      //updatePresence()
      // perform actions when the process ends
      // add your desired actions here
    }
  });
};

// check the process every 5 seconds (you can adjust the interval as needed)
setInterval(checkProcess, 5000);