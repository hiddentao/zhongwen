# ZhongWen web app #

This is the source code to the [http://zhongwen.co.uk] mobile web app. It is for practising Mandarin writing and
translation and is based on the syllabus from the [MECS study program](http://www.meridiandao.co.uk/).

This app is built using:

* [jQuery Mobile](https://github.com/jquery/jquery-mobile)
* [Coffeescript](https://github.com/jashkenas/coffee-script)
* [Spine](http://github.com/maccman/spine)
* [Weber](http://github.com/hiddentao/weber).

## Dev notes ##

I tried implementing HTML 5 canvas-based stroke input using code from [http://jabtunes.com/notation/chinesestroke.html]
but it found the matching algorithm to be too poor for non-trivial characters. You can see how far I got by checking
out the **canvas_stroke_input** branch in the repo.

For now you can input pinyin or mandarin characters directly if you have a Chinese input support installed for your
keyboard.

Tested on desktop (Chrome, Firefox) and mobile (iOS, Android).

Blog post: [link](http://www.hiddentao.com/archives/2012/03/14/zhongwen-co-uk-a-simple-jquery-mobile-web-app/)

## License ##

GNU Affero GPL v3 (see LICENSE.txt).

