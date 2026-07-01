package logic_test

import (
	"testing"

	"github.com/kriratik/go-pipeline/logic"
)

func Test_Sum(t *testing.T) {
	a := logic.Sum(1, 3)

	if a != 4 {
		t.Errorf("Expect 4 but got %d", a)
	}
}

func Test_Mod(t *testing.T) {
	a := logic.Mod(1, 3)

	if a != 1 {
		t.Errorf("Expect 1 but got %d", a)
	}
}
