package mapping_test

import (
	"testing"

	"github.com/kriratik/go-pipeline/mapping"
)

func TestMapping(t *testing.T) {
	s := mapping.MapToMock("aa", 1.0)

	if s.A != "aa" {
		t.Errorf("Expect AA but got %s", s.A)
	}

	if s.Value != 1.0 {
		t.Errorf("Expect 1.0 but got %f", s.Value)
	}
}
