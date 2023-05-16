package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"
)

type Network struct {
	LocalAddress  string `json:"localAddress"`
	RemoteAddress string `json:"remoteAddress"`
	Inbound       bool   `json:"inbound"`
	Trusted       bool   `json:"trusted"`
	Static        bool   `json:"static"`
}

type Result struct {
	Enr       string              `json:"enr"`
	Enode     string              `json:"enode"`
	ID        string              `json:"id"`
	Name      string              `json:"name"`
	Network   Network             `json:"network"`
}

type Root struct {
	Jsonrpc string   `json:"jsonrpc"`
	ID      int      `json:"id"`
	Result  []Result `json:"result"`
}

func main() {
	ip := flag.String("ip", "", "The IP address of the node")
	flag.Parse()

	if *ip == "" {
		panic("The 'ip' flag is required.")
	}

	for {
		getPeers(ip)
		fmt.Println("Sleeping for 5 seconds...")
		time.Sleep(5 * time.Second)
	}
}

func getPeers(ip *string) {

	data := `{"jsonrpc":"2.0","method":"admin_peers","id":0}`
	body := bytes.NewBuffer([]byte(data))

	url := fmt.Sprintf("http://%s:8545", *ip)
	req, err := http.NewRequest("POST", url, body)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	var root Root
	err = json.Unmarshal(respBody, &root)
	if err != nil {
		panic("Error reading HTTP response")
	}

	for _, result := range root.Result {
		fmt.Println("***********************************************************************************************")
		fmt.Println("Enr: ", result.Enr)
		fmt.Println("Enode: ", result.Enode)
		fmt.Println("ID: ", result.ID)
		fmt.Println("Name: ", result.Name)

		// Access network details
		fmt.Println("Network LocalAddress: ", result.Network.LocalAddress)
		fmt.Println("Network RemoteAddress: ", result.Network.RemoteAddress)
		fmt.Println("Network Inbound: ", result.Network.Inbound)
		fmt.Println("Network Trusted: ", result.Network.Trusted)
		fmt.Println("Network Static: ", result.Network.Static)
	}
}
