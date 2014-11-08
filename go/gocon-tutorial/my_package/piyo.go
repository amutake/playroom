package my_package

// 関数のリストを書く
type Piyo interface {
	C() string
	D() int
}

type PiyoImpl struct {
}

func (p *PiyoImpl) C() string {
	return "hoge"
}

func (p *PiyoImpl) D() int {
	return 0
}

func init() {
	var r io.Reader
	var piyo Piyo
	piyo = &PiyoImpl{}
}
