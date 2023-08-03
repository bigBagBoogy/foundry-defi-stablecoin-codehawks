// your_script.js
document.addEventListener("DOMContentLoaded", function () {
  // Load the ABI from the JSON file
  fetch("abi.json")
    .then((response) => response.json())
    .then((abi) => {
      // Replace 'YourContractAddress' with the actual contract address
      const contractAddress = "0x3e899202640a3135A9D6E540938Ab35D364CF0f5";

      // Replace 'web3Provider' with your actual web3 provider (e.g., Metamask)
      const web3Provider = new Web3.providers.HttpProvider(
        "http://localhost:8545"
      );
      const web3 = new Web3(web3Provider);
      const contract = new web3.eth.Contract(abi, contractAddress);

      // Your contract interaction code goes here
    })
    .catch((error) => console.error("Error loading contract ABI:", error));
});
