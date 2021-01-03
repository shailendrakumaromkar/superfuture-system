import React, { Component } from 'react';
import Web3 from 'web3';
//import logo from '../logo.png';
import './App.css';
import Betting from '../build/contracts/Betting.json';
class App extends Component {

  async componentWillMount() {
    await this.loadWeb3()
    await this.loadBlockchainData()
    //console.log(window.web3);
  }

  async loadWeb3() {
    // window.addEventListener('load', async () => {
      // Modern dapp browsers...
      if (window.ethereum) {
          window.web3 = new Web3(window.ethereum)
          try {
              // Request account access if needed
              await window.ethereum.enable()
              // Acccounts now exposed
              //web3.eth.sendTransaction({/* ... */});
          } catch (error) {
              // User denied account access...
          }
      }
      // Legacy dapp browsers...
      else if (window.web3) {
          window.web3 = new Web3(window.web3.currentProvider);
          // Acccounts always exposed
          //web3.eth.sendTransaction({/* ... */});
      }
      // Non-dapp browsers...
      else {
          window.alert('Non-Ethereum browser detected. You should consider trying MetaMask!');
      }
  
  }

  async loadBlockchainData() {
    const web3= window.web3
    const accounts= await web3.eth.getAccounts()
    //console.log(accounts)
    this.setState({account:accounts[0]})
    //console.log(Betting.abi, Betting.networks[5777].address)
    
    
    const networkId= await web3.eth.net.getId()
    const networkData=Betting.networks[networkId]
    if(networkData) {
      
      const betting = web3.eth.Contract(Betting.abi,networkData.address)
      //console.log(betting)
      this.setState({betting})
      const playerList = await betting.methods.players().call()
      //console.log(playerList.toString())
      this.setState({playerList})

      for (var i=1;i<=playerList;i++) {
        const product = await betting.methods.playerList(i).call()
        this.setState({
          products:[...this.state.playerList,playerList]
        })
      }
      
      const playersTotalBet = await betting.methods.playersTotalBet().call()
      //console.log(playerList.toString())
      this.setState({playersTotalBet})
      this.setState({loading:false})
    
    } else {
      window.alert('Betting not deployed to detected network')
    }

    //console.log(networkId)
    //console.log(betting)
  }

  constructor(props)  {
    super(props)
    this.state={
      playerList,
      playersTotalBet
    }
   }

  render() {
    return (
      <div>
        <Navbar account={this.state.account} />
        <div className="container-fluid mt-5">
            <div className="row">
              <main role="main" className="col-lg-12 d-flex">
                { this.state.loading 
                 playerList,
                 playersTotalBet
                }
              </main>
            </div>
          </div>
      </div>   
    );
  }
}

export default App;
