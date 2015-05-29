
 GenerateHarmony.lua
 ver 1.0.1.1
 任意音程のハモリを生成。

 Copyright (C) 2012 ちょむＰ / VOCALOMAKETS


■つかいかた

※JobPluginのインストールの方法は割愛します。

１．新しいトラックを作ります。
　　（メニューの　トラック＞トラックの追加 ）

２．ハモらせたいメロが入ったパートをそこにコピーします。
　　（[CTRL]押しながらパートをマウスドラッグでコピーできます。）

３．コピーしてきたパートに対してこのスクリプトを実行します。
　　実行範囲はパート内全体です。部分的に使用したい場合は
　　パートを区切ってください。曲を複数のパートに区切り
　　それぞれ個別に実行することにより転調にも対応します。

４．ダイアログが出てくるのでキーと移動音程を指定します。
　　ちなみにメジャースケールのみ対応します。
　　ナチュラルマイナーであれば三度上をルート音にすればOK。
　　(Ａナチュラルマイナー＝Ｃメジャー）

　※音程は八度上（オクターブ上）がデフォルトになってるので注意してください。
　　デフォルト値を変更する方法がわかりませんでした。
　　知っている方教えてください…

５．するとあらふしぎ！　３度上のハモリが生成されます。



■注意点など

　・このスクリプトには V3JobPlugin API Wrapper を使用しています。
　　作者の TomomiSaito 氏にこの場を借りてお礼申し上げます。

　・新しいトラックやパートの生成も自動でやりたかった…
　　方法を知っている方教えてください…

　・移動音程コンボボックスのデフォルト値を変更する方法がわかりませんでした。
　　方法を知っている方教えてください…

　・ダイアトニックスケール外のノートの移調は主観で適当に決めてあります。
　　特にG#をAbと考えるかどうかは微妙なところ。

　個人的には現状の仕様で不自由ないですが要望がありましたら考えます。
  お問い合わせ先： Twitter: @chom (ちょむＰ) / メール: info@chomstudio.com


■バージョン履歴

ver. 1.0.1
　公開。



----------------------------------
V3JobPlugin API Wrapper ライセンス
----------------------------------

本ソフトウェアはMIT license（以下、「MITL」）および「VOCALOID(TM)3 Job Plugin 
Development Kit（以下、「V3DK」）」エンドユーザー使用許諾契約書（以下、「使用許
諾」）に基づき利用を許可します。

本ソフトウェアのJobプラグインAPIのコードを含んだ部分はV3DK使用許諾の定める範囲
において使用しなければなりません。
JobプラグインAPIのコードを含まない部分、またはそれを除いた部分はMITLの下、自由
に利用することができます。

V3DK使用許諾の全文は当該製品の配布元より入手してください。
http://vocaloidstore.com/


The MIT License
---------------

    Copyright (c) 2011 TomomiSaito

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
