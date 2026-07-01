package mapping

type Mock struct {
	A     string
	Value float64
}

func MapToMock(name string, value float64) Mock {
	return Mock{
		A:     name,
		Value: value,
	}
}
