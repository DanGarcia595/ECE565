package main

import (
	"fmt";
	"os";
	"bufio";
	"strings";
	"math/rand";
	"strconv";
	"time"
)

var physicalsize = 8
var offsetsize uint = 1
var vaddrsize uint = 5

func main(){
	file, err := os.Open("ece565hw03.txt") // just pass the file name
    if err != nil {
        fmt.Print(err)
	}
	addresses := make(chan int)
	scanner := bufio.NewScanner(file)
	pagetable := make([][]string, 0)
	physicaltable := make([]bool, physicalsize)
	for scanner.Scan() {
		values := strings.Split(strings.TrimSpace(scanner.Text()), "\t")
		pagetable = append(pagetable,values)
	}
	for _,element := range pagetable{
		if(element[1] == "v"){
			index, _ := strconv.Atoi(element[0])
			physicaltable[index] = true
		}
	}
	fmt.Println(physicaltable)
	fmt.Println(pagetable)
	go generateAdresses(addresses)
	go translateAdress(physicaltable, pagetable, addresses)
	for{
		//fmt.Println(<-addresses)
	}
}

func generateAdresses(out chan<- int){
	for{
		adr := rand.Intn((1<<vaddrsize)-1)
		fmt.Print("Virtual Address: ")
		fmt.Printf("%02d",adr)
		fmt.Print(" | ")
		out <- adr
		time.Sleep(time.Millisecond * 1)
	}
}

func translateAdress(physicaltable []bool,pagetable [][]string, in <-chan int){
	evicted := 0
	found := false
	for{
		found = false
		vaddress := <-in 
		page := vaddress >> offsetsize
		offset := vaddress % (1<<offsetsize)
		valid := pagetable[page][1]
		fmt.Print("Page: ")
		fmt.Printf("%02d",page)
		fmt.Print(" | Offset: ",offset," | Valid: ",valid, " |")
		if(valid == "v"){
			frame, err := strconv.Atoi(pagetable[page][0])
			if err != nil {
				fmt.Print(err)
			}
			paddress := (frame << offsetsize) + offset
			fmt.Println(" Physical Address ",paddress)
		}else{
			fmt.Print(" Page fault! Adding page to table | ")
			for index,element := range physicaltable{
				if element == false{
					pagevalue := strconv.Itoa(index)
					pagetable[page][0] = pagevalue
					pagetable[page][1] = "v"
					physicaltable[index] = true
					found = true
					fmt.Println("Free Space Found at ",index)
					break
				}
			}
			if found != true{
				fmt.Println("Evicting Address ",evicted)
				pagevalue := strconv.Itoa(evicted)
				for index,element := range pagetable{
					if (element[0] == pagevalue) && (element[1] == "v"){
						pagetable[index][1] = "i"
					}
				}
				pagetable[page][0] = pagevalue
				pagetable[page][1] = "v"

				evicted = (evicted + 1) % physicalsize			
			}
		}
	}
}