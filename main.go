package main

import (
	"fmt"
)

func main() {
	fmt.Println("Start service")

	fmt.Println(Summary())
}

func Summary() int64 {
	return 4
}
