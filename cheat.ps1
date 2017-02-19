#####################################################################################
#                                                                 
#                       绍兴市职教中心 打字测验2.0(网络版)        
#                 
#                                                   的打字外挂    by GEEKiDoS           
#                                    
#       由本脚本产生的一切后果作者皆不负责
#
#       如 作者/老师 看见，请尽快使用WPF等无标准窗口句柄的UI库编写,谢谢！
#
#               开源协议:WTFPL (http://www.wtfpl.net/)
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#                 Copyright (C) 2004 Sam Hocevar
#
#       Everyone is permitted to copy and distribute verbatim or modified
#       copies of this license document, and changing it is allowed as long
#       as the name is changed.
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#       TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#             0. You just DO WHAT THE FUCK YOU WANT TO.
#
####################################################################################
# 引用 .NET 程序集
$null = Add-Type -AssemblyName System.Windows.Forms -PassThru

# 用一下VB的InputBox
# InputBox
# [Microsoft.VisualBasic.Interaction]::InputBox("Prompt", "Title", "Default", -1, -1);
$null = Add-Type -Assemblyname Microsoft.VisualBasic -PassThru
# 引用 Win32 API
$WApi = Add-Type @"
[DllImport("user32.dll")]
public static extern int FindWindow(string Classname,string WindowName);
[DllImport("user32.dll")]
public static extern int FindWindowEx(int hwndup,int hwnddown,string classname,string windowname);
[DllImport("user32.dll")]
public static extern int SendMessage(int hWnd,uint Msg,int p1,System.Text.StringBuilder p2);
[DllImport("user32.dll")]
public static extern int SetActiveWindow(int hWnd);
[DllImport("user32.dll")]
public static extern int SetForegroundWindow(int hWnd);
"@ -PassThru -Name Win32Api
# WPF程序集
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
# XAML 界面代码
[xml]$UI = @"
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="打字外挂 PowerShell 版 v1.4" Height="330" Width="629">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition/>
        </Grid.ColumnDefinitions>
        <TextBox Name="Words" Margin="10,10,10,74" TextWrapping="Wrap" IsEnabled="False"/>
        <Button Name="btnStart" Content="开始!" HorizontalAlignment="Right" Height="31" Margin="0,0,22,34" VerticalAlignment="Bottom" Width="124"/>
        <Button Name="btnStop" Content="获取内容" HorizontalAlignment="Right" Height="31" Margin="0,0,152,34" VerticalAlignment="Bottom" Width="124"/>
        <StatusBar Height="23" VerticalAlignment="Bottom">
            <TextBlock Name="Status" Height="23" TextWrapping="Wrap" Text="空闲" Width="611"/>
        </StatusBar>
        <TextBlock Name="textBlock" Height="19" Margin="22,0,0,37" TextWrapping="Wrap" Text="目标速度:" VerticalAlignment="Bottom" HorizontalAlignment="Left" Width="63"/>
        <TextBox Name="Speed" HorizontalAlignment="Left" Height="19" Margin="85,0,0,39" TextWrapping="Wrap" Text="200" VerticalAlignment="Bottom" Width="87"/>
        <CheckBox Name="AutoStart" Content="自动开始" IsChecked="true" Height="19" Margin="193,0,310,37" VerticalAlignment="Bottom"/>

    </Grid>
</Window>
"@

# 检测是否为空
function IsNullOrEmpty($objectToCheck) {
    if ($objectToCheck -eq $null) {
        return $true
    }

    if ($objectToCheck -is [String] -and $objectToCheck -eq [String]::Empty) {
        return $true
    }

    if ($objectToCheck -is [DBNull] -or $objectToCheck -is [System.Management.Automation.Language.NullString]) {
        return $true
    }

    if ($objectToCheck -eq "") {
        return $true
    }

    return $false
}

# 查找窗口
function WaitForWindow {
    $isLaunched = $false

    # 这是管道
    Get-Process | ForEach-Object {
        if($($_.ProcessName) -eq "打字测验") {
        $isLaunched = $true
    }
}
while(-not $isLaunched) {
    Write-Host "你特么都没开，等待程序启动(下一次检测2秒后)"
    [System.Threading.Thread]::Sleep(2000)
    Get-Process | ForEach-Object {
        if($_.ProcessName -eq "打字测验") {
            $isLaunched = $true
        }
    }
}
Clear-Host
}

function WaitForWindowUI {
    $isLaunched = $false

    # 这是管道
    Get-Process | ForEach-Object {
        if($($_.ProcessName) -eq "打字测验") {
        $isLaunched = $true
    }
}
while(-not $isLaunched) {
    $Status.Text = "你特么都没开，等待程序启动(下一次检测2秒后)"
    [System.Threading.Thread]::Sleep(2000)
    Get-Process | ForEach-Object {
        if($_.ProcessName -eq "打字测验") {
            $isLaunched = $true
        }
    }
}
Clear-Host
}

# 检测是否在主界面
function WaitForMode {
    $isMain = $true
    if($WApi::FindWindow("ThunderRT6MDIForm","打字练习网络版_V2.0") -eq 0) {
        $isMain = $false
    }
    while ($isMain) {
        Write-Output "你特么还在主界面!(下一次检测2秒后)"
        [System.Threading.Thread]::Sleep(2000)
        if($WApi::FindWindow("ThunderRT6MDIForm","打字练习网络版_V2.0") -eq 0) {
            $isMain = $false
        }
    }
    Clear-Host
}

function WaitForModeUI {
    $isMain = $true
    if($WApi::FindWindow("ThunderRT6MDIForm","打字练习网络版_V2.0") -eq 0) {
        $isMain = $false
    }
    while ($isMain) {
        $Status.Text = "你特么还在主界面!(下一次检测2秒后)"
        [System.Threading.Thread]::Sleep(2000)
        if($WApi::FindWindow("ThunderRT6MDIForm","打字练习网络版_V2.0") -eq 0) {
            $isMain = $false
        }
    }
    Clear-Host
}

# 获取富文本框及窗口HWND
function GetHWND {
    $mode
    while($true){
        "全体键","联网考试","FSJL练习","ADKJ练习","GHRU练习","TVYM练习","ELC,练习","BN练习","WZO/练习","QXP.练习","数字键一" | ForEach-Object {
            if(!($WApi::FindWindow("ThunderRT6MDIForm","打字练习网络版_V2.0 - ["+ $_ +"]")) -eq 0) {
                $mode = $_
                break
            }
        }
        if( IsNullOrEmpty($mode) ) {
            Write-Host "未自动搜索到模式，请手动输入模式后回车(若希望重新搜索则直接回车):"
            $mode = (Read-Host)
        }
        if (-not (IsNullOrEmpty($mode)) ) {
            if(!($WApi::FindWindow("ThunderRT6MDIForm","打字练习网络版_V2.0 - ["+ $_ +"]")) -eq 0) {
                break
            } else {
                Write-Host "未检测到该模式正在运行,正在自动重新搜索....."
                $mode = $null
            }
        }
    }
    $return = 0,0
    $return[0] = $temp = $WApi::FindWindow("ThunderRT6MDIForm","打字练习网络版_V2.0 - ["+ $mode +"]")
    $temp = $WApi::FindWindowEx($temp,0,"MDIClient",$null)
    $temp = $WApi::FindWindowEx($temp,0,"ThunderRT6FormDC",$mode)
    $return[1] = $WApi::FindWindowEx($temp,0,"RichTextWndClass",$null)
    if ($return[0] -eq 0 -or $return[1] -eq 0) {
        Write-Error "无法检测模式"
    }
    return $return
        
}

function GetHWNDUI {
    $mode
    while($true){
        "全体键","联网考试","FSJL练习","ADKJ练习","GHRU练习","TVYM练习","ELC,练习","BN练习","WZO/练习","QXP.练习","数字键一" | ForEach-Object {
            if(!($WApi::FindWindow("ThunderRT6MDIForm","打字练习网络版_V2.0 - ["+ $_ +"]")) -eq 0) {
                $mode = $_
                break
            }
        }
        if( IsNullOrEmpty($mode) ) {
            $mode = [Microsoft.VisualBasic.Interaction]::InputBox("提示", "未自动搜索到模式，请手动输入模式", "一级简码练习", -1, -1); 
            
        }
        if (-not (IsNullOrEmpty($mode)) ) {
            if(!($WApi::FindWindow("ThunderRT6MDIForm","打字练习网络版_V2.0 - ["+ $_ +"]")) -eq 0) {
                break
            } else {
                $Status.Text = "未检测到该模式正在运行,正在自动重新搜索....."
                $mode = $null
            }
        }
    }
    $return = 0,0
    $return[0] = $temp = $WApi::FindWindow("ThunderRT6MDIForm","打字练习网络版_V2.0 - ["+ $mode +"]")
    $temp = $WApi::FindWindowEx($temp,0,"MDIClient",$null)
    $temp = $WApi::FindWindowEx($temp,0,"ThunderRT6FormDC",$mode)
    $return[1] = $WApi::FindWindowEx($temp,0,"RichTextWndClass",$null)
    if ($return[0] -eq 0 -or $return[1] -eq 0) {
        Write-Error "无法检测模式"
    }
    return $return
        
}

function GetInnerText($HWNDs) {
    $word = New-Object System.Text.StringBuilder(3001)
    $null = $WApi::SendMessage($HWNDs[2],0x000D,3001,$word)
    # 如为联网考试模式则检测试卷是否下发
    if($mode -eq "联网考试") {
        while($true) {
            if($word.ToString() -eq "") {
                Write-Output "检测到模式为联网考试，正在等待试卷"
                [System.Threading.Thread]::Sleep(1000)
            }
            else {
                break
            }
            $null = $WApi::SendMessage($HWNDs[2],0x000D,3001,$word)
        }
    }
    return $word.ToString()
}

function GetInnerTextUI($HWNDs) {
    $word = New-Object System.Text.StringBuilder(3001)
    $null = $WApi::SendMessage($HWNDs[2],0x000D,3001,$word)
    # 如为联网考试模式则检测试卷是否下发
    if($mode -eq "联网考试") {
        while($true) {
            if($word.ToString() -eq "") {
                $Status.Text =  "检测到模式为联网考试，正在等待试卷"
                [System.Threading.Thread]::Sleep(1000)
            }
            else {
                break
            }
            $null = $WApi::SendMessage($HWNDs[2],0x000D,3001,$word)
        }
    }
    return $word.ToString()
}


# MAIN

# 设置标题
[Console]::Title = "打字外挂Powershell版 v1.4"

if($args.Length -gt 0 -and $args[0] -eq "-Console") {
	Clear-Host
    Write-Host "此脚本只用于学习以及交流,由本脚本产生的一切后果作者皆不负责!`r`n`r`nGUI版本已经制作完毕,但可能会有很多bug,可以去除 -Console 参数前往体验`r`n按任意键继续"
	$null = [Console]::ReadKey()
	Clear-Host
    WaitForWindow
    WaitForMode
    $HWNDs = GetHWND
    $Text = GetInnerText($HWNDs)


    # 参数设置
    Write-Host 已获取到内容:
    Write-Host $Text -ForegroundColor Green

    Write-Host "输入目标速度:"
    $l = [convert]::ToInt32([Console]::ReadLine())
    Write-Host "自动开始? Y/N (Y) "
    $a = [Console]::ReadKey()
    Write-Host "`0"
    $timeout = 1000 / ($l / 60)
    Write-Host "按任意键开始,想要停止回到此窗口并按Ctrl+C"
    $null = [Console]::ReadKey()

    # 开始吔屎
    $null = $WApi::SetForegroundWindow($HWNDs[1])

    if($a.keychar -eq 'y') {
        [System.Windows.Forms.SendKeys]::SendWait("{F10}{Enter}")
    }
    if($a.key.tostring().toupper() -eq "ENTER") {
        [System.Windows.Forms.SendKeys]::SendWait("{F10}{Enter}")
    }
    for($i=0;$Text.length -gt $i;$i++) {
        [System.Windows.Forms.SendKeys]::SendWait(($Text)[$i].ToString())
        [System.Threading.Thread]::Sleep($timeout)
    }

    # 结束
    Write-Host 按任意键退出
    $temp = [Console]::ReadKey()
} else {
	Clear-Host
    [System.Windows.MessageBox]::Show("此脚本只用于学习以及交流,由本脚本产生的一切后果作者皆不负责!`r`n`r`n以及可能全是bug,如果遇到了非常大的bug请考虑添加 -Console 参数启动控制台版","警告")
    # 加载UI
    $reader=(New-Object System.Xml.XmlNodeReader $UI) 
    try{
        $Form = [Windows.Markup.XamlReader]::Load( $reader )
    }
    catch{
        Write-Host "无法加载WPF程序集来显示UI，请考虑使用 -Console 启动控制台版本"
        exit
    }
    $UI.SelectNodes("//*[@Name]") | ForEach-Object {
        Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)
    }

    $StatusID = 0

    #$Job

    $btnStart.Add_Click({
            switch ($StatusID) {
                0 { 
                    $btnStart.Content = "运行中"
                    $StatusID = 1
                    $btnStop.Content = "暂停"
                    if(!$Speed.Text -is [int]) {
                        [System.Windows.MessageBox]::Show("速度不是数字，请重新输入!")
                        break
                    }
                    WaitForWindowUI
                    $Status.Text = "运行中..."
                    WaitForModeUI
                    $Status.Text = "运行中..."
                    $HWNDs = GetHWNDUI
                    $Status.Text = "运行中..."
                    $Words.Text = $Text = GetInnerTextUI($HWNDs)
                    $Status.Text = "运行中..."
                    $SpeedInt = [Convert]::ToInt32($Speed.Text)
                    $Tick = 1000 / ( $SpeedInt / 60)
                    # 开始吔屎
                    $null = $WApi::SetForegroundWindow($HWNDs[1])

                    if($AutoStart.IsChecked -eq $true) {
                        [System.Windows.Forms.SendKeys]::SendWait("{F10}{Enter}")
                    }
                    
                    #$Job = Start-Job -Script {
                        for($i=0;$Text.length -gt $i;$i++) {
                            [System.Windows.Forms.SendKeys]::SendWait(($Text)[$i].ToString())
                            [System.Threading.Thread]::Sleep($Tick)
                        }
                    #}
                    #Wait-Job $Job
                    #Remove-Job $Job
                    #$Job = $null
                    $Status.Text = "空闲"
                    $btnStart.Content = "开始"
                    $btnStop.Content = "获取内容"
                    $StatusID = 0
                }
                1 {  

                }
                2 {  
                    Resume-Job $Job
                }
                Default {
                }
            }

        })
    $btnStop.Add_Click({
#            switch ($StatusID) {
#                0 {  
                    $HWNDs = GetHWNDUI
                    $Words.Text = $Text = GetInnerTextUI($HWNDs)
#                }
#                1 {
#                    Suspend-Job $Job
#                    $btnStart.Content = "继续"
#                    $btnStop.Content = "停止"
#                    $Status.Text = "暂停中"
#                    $StatusID = 2
#               }
#                2 {
#                    Stop-Job $Job
#                    Remove-Job $Job
#                    $Job = $null
#                    $Status.Text = "空闲"
#                    $btnStart.Content = "开始"
#                    $btnStop.Content = "获取内容"
#                    $StatusID = 0
#                }
#                Default {
#                
#                }
#            }
       })
    $Form.ShowDialog()
}