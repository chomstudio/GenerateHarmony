-- 
-- GenerateHarmony.lua
-- ver. 1.0.1.1
-- 任意音程のハモリを生成。
--
-- Copyright (C) 2012 ちょむＰ / VOCALOMAKETS
-- 
-- 使用方法や諸注意についてはreadme.txtをご覧下さい。

--
-- プラグインマニフェスト関数.
--
function manifest()
	myManifest = {
		name          = "Generate Harmony",
		comment       = "任意音程のハモリを生成。",
		author        = "ちょむＰ / VOCALOMAKETS_135",
		pluginID      = "{D03822D9-028E-467b-A2E5-621CE195F53D}",
		pluginVersion = "1.0.1.1",
		apiVersion    = "3.0.0.1"
	}

	return myManifest
end


--
-- VOCALOID3 Lua スクリプトのエントリポイント.
--
function main(processParam, envParam)
	-- ルート音テーブル
	local tonelist = { "Ｃ","Ｃ♯","Ｄ","Ｅ♭","Ｅ","Ｆ","Ｆ♯","Ｇ","Ｇ♯","Ａ","Ｂ♭","Ｂ" }
	
	-- 音程指定
	local shiftlist = { 
		"八度上（オクターブ）"
		,"七度上"
		,"六度上"
		,"五度上"
		,"四度上"
		,"三度上"
		,"二度上"
		,"変更しない"
		,"二度下"
		,"三度下"
		,"四度下"
		,"五度下"
		,"六度下"
		,"七度下"
		,"八度下（オクターブ）" }
	
	-- 変換テーブル
	local toneshifttable = {}
	toneshifttable[ 1] = {  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	toneshifttable[ 2] = {  2, 1, 2, 2, 1, 2, 1, 2, 1, 2, 2, 1 }
	toneshifttable[ 3] = {  4, 3, 3, 4, 3, 4, 3, 4, 3, 3, 4, 3 }
	toneshifttable[ 4] = {  5, 4, 5, 6, 5, 6, 5, 5, 4, 5, 6, 5 }
	toneshifttable[ 5] = {  7, 6, 7, 8, 7, 7, 6, 7, 6, 7, 7, 6 }
	toneshifttable[ 6] = {  9, 8, 9, 9, 8, 9, 8, 9, 8, 8, 9, 8 }
	toneshifttable[ 7] = { 11,10,10,11,10,11,10,10, 9,10,11,10 }
	toneshifttable[ 8] = { 12,12,12,12,12,12,12,12,12,12,12,12 }
	
	-- リターンコード
	local retCode = 0
	
	-- ルート音ID
	local rootToneID = 0
	
	-- 移動音程ID
	local shiftID = 0
	
	-- オク下げフラグ
	local okusage = false
	
	
	-- スクリプトからの相対パスでVSWを読み込みます
	assert(loadfile(envParam.scriptDir .. "./V3JobPluginAPIWrapper.min.lua"))()
	VSWrapper:import()
	
	-- **********************************************************
	-- ダイアログの生成
	local dialog = Dialog:new()
	dialog:setTitle("Jobプラグインパラメータ入力")
	dialog:addList("rootToneStr", "ルート音（メジャースケールのみ）", tonelist )
	dialog:addList("shiftStr", "音程", shiftlist )
	
	-- ダイアログを表示
	-- OKボタンが押されなかったら終了
	if not dialog:show():isOk() then
		return 0
	end
	
	-- ダイアログから入力値を取得
	local dlgStatus = dialog:values()
	
	-- せっかくなのでDataListを使ってindexをサーチ
	local tabToneList  = DataList:new(tonelist)
	local tabShiftList = DataList:new(shiftlist)
	
	rootToneID = tabToneList:indexOf(dlgStatus.rootToneStr)
	shiftID    = tabShiftList:indexOf(dlgStatus.shiftStr)
	
	-- 数値エラーチェック
	if rootToneID == nil or shiftID == nil then 
		-- エラー
		MsgBox:ok("内部エラー：リスト指定範囲外")
		return 1
	end
	
	-- **********************************************************
	-- 音程の計算
	-- ID 1=８度上 2=７度上… 7=二度上 8=変更しない 9=二度下 10=三度下…
	
	-- 8=変更しない
	if shiftID == 8 then
		-- 変更しないんなら仕方ないね
		return 0
	end
	
	shiftID = 9 - shiftID
	-- ID 8=８度上 7=７度上… 2=二度上 1=変更しない 0=二度下 -1=三度下…
	
	if shiftID < 1 then
		okusage = true
		shiftID = shiftID + 7
		-- 7=二度下 6=三度下…
	end
	
	-- **********************************************************
	-- ボカロエディタからノートを取得します
	local noteExList = VSWrapper:listNoteEx()
	
	-- 読み込んだノートの総数
	if (noteExList:count() == 0) then
		MsgBox:ok("エラー：指定範囲内にノートがありません。")
		return 1
	end
	
	-- **********************************************************
	-- 取得したノートイベントを更新します
	for idx, updNoteEx in noteExList:each() do
		
		-- ノートナンバーゲット
		local noteNum = updNoteEx:noteNum()
		
		-- キーをCに合わせる C -> rootToneID = 1
		noteNum = noteNum - (rootToneID - 1)
		
		-- 音階の計算
		local mod = noteNum % 12
		
		-- 変換テーブルから値を調べてノード移動
		noteNum = noteNum + toneshifttable[shiftID][mod+1]
		
		-- オク下げフラグが立ってたらオク下げ
		if okusage == true then 
			noteNum = noteNum - 12
		end
		
		-- キーを元に戻す
		noteNum = noteNum + (rootToneID - 1)
		
		-- 範囲チェック
		if noteNum < 0   then 
			noteNum = 0
		end
		if noteNum > 127 then 
			noteNum = 127
		end
		
		-- 新しいノートナンバーセット
		updNoteEx:noteNum(noteNum)
		
		-- 更新
		if not updNoteEx:update() then
			MsgBox:ok("内部エラー：ノート更新エラー")
			return 1
		end
	end

	-- 正常終了.
	return 0

end
