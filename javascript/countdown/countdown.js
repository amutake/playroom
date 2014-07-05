(function() {

    var rain = false;

    var andonStart = new Date(2014, 6, 11, 18, 50, 0);
    var andonEnd = new Date(2014, 6, 11, 20, 30, 0);

    if (rain) {
        var andonStart = new Date(2014, 6, 14, 18, 50, 0);
        var andonEnd = new Date(2014, 6, 14, 20, 30, 0);
    }

    var diff = andonStart.getTime() - andonEnd.getTime();

    var japanese = function(c) {
        return "行灯行列開始まであと " + c.days + " 日 " + c.hours + " 時間 " + c.minutes + " 分 " + c.seconds + " 秒 ";
    }

    var elem = document.getElementById("countdown");

    var timer = countdown(
        function(c) {
            if (c.value > 0) {
                var text = japanese(c);
                elem.innerHTML = text;
            } else if (c.value > diff) {
                var text = "行灯行列中！";
                elem.innerHTML = text;
            } else {
                var text = "行灯行列終了！";
                elem.innerHTML = text;
            }
        },
        andonStart,
        countdown.DEFAULTS
    );
})();
