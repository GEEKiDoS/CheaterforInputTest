#####################################################################################
#                                                                 
#                       ������ְ������ ���ֲ���2.0(�����)        
#                 
#                                                   �Ĵ������    by GEEKiDoS           
#                                    
#       �ɱ��ű�������һ�к�����߽Բ�����
#
#       �� ����/��ʦ �������뾡��ʹ��WPF���ޱ�׼���ھ����UI���д,лл��
#
#               ��ԴЭ��:WTFPL (http://www.wtfpl.net/)
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
# ���� .NET ����
$null = Add-Type -AssemblyName System.Windows.Forms -PassThru

# ��һ��VB��InputBox
# InputBox
# [Microsoft.VisualBasic.Interaction]::InputBox("Prompt", "Title", "Default", -1, -1);
$null = Add-Type -Assemblyname Microsoft.VisualBasic -PassThru
# ���� Win32 API
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
# WPF����
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
# XAML �������
[xml]$UI = @"
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="������� PowerShell �� v1.4" Height="330" Width="629">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition/>
        </Grid.ColumnDefinitions>
        <TextBox Name="Words" Margin="10,10,10,74" TextWrapping="Wrap" IsEnabled="False"/>
        <Button Name="btnStart" Content="��ʼ!" HorizontalAlignment="Right" Height="31" Margin="0,0,22,34" VerticalAlignment="Bottom" Width="124"/>
        <Button Name="btnStop" Content="��ȡ����" HorizontalAlignment="Right" Height="31" Margin="0,0,152,34" VerticalAlignment="Bottom" Width="124"/>
        <StatusBar Height="23" VerticalAlignment="Bottom">
            <TextBlock Name="Status" Height="23" TextWrapping="Wrap" Text="����" Width="611"/>
        </StatusBar>
        <TextBlock Name="textBlock" Height="19" Margin="22,0,0,37" TextWrapping="Wrap" Text="Ŀ���ٶ�:" VerticalAlignment="Bottom" HorizontalAlignment="Left" Width="63"/>
        <TextBox Name="Speed" HorizontalAlignment="Left" Height="19" Margin="85,0,0,39" TextWrapping="Wrap" Text="200" VerticalAlignment="Bottom" Width="87"/>
        <CheckBox Name="AutoStart" Content="�Զ���ʼ" IsChecked="true" Height="19" Margin="193,0,310,37" VerticalAlignment="Bottom"/>

    </Grid>
</Window>
"@

# ����Ƿ�Ϊ��
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

# ���Ҵ���
function WaitForWindow {
    $isLaunched = $false

    # ���ǹܵ�
    Get-Process | ForEach-Object {
        if($($_.ProcessName) -eq "���ֲ���") {
        $isLaunched = $true
    }
}
while(-not $isLaunched) {
    Write-Host "����ô��û�����ȴ���������(��һ�μ��2���)"
    [System.Threading.Thread]::Sleep(2000)
    Get-Process | ForEach-Object {
        if($_.ProcessName -eq "���ֲ���") {
            $isLaunched = $true
        }
    }
}
Clear-Host
}

function WaitForWindowUI {
    $isLaunched = $false

    # ���ǹܵ�
    Get-Process | ForEach-Object {
        if($($_.ProcessName) -eq "���ֲ���") {
        $isLaunched = $true
    }
}
while(-not $isLaunched) {
    $Status.Text = "����ô��û�����ȴ���������(��һ�μ��2���)"
    [System.Threading.Thread]::Sleep(2000)
    Get-Process | ForEach-Object {
        if($_.ProcessName -eq "���ֲ���") {
            $isLaunched = $true
        }
    }
}
Clear-Host
}

# ����Ƿ���������
function WaitForMode {
    $isMain = $true
    if($WApi::FindWindow("ThunderRT6MDIForm","������ϰ�����_V2.0") -eq 0) {
        $isMain = $false
    }
    while ($isMain) {
        Write-Output "����ô����������!(��һ�μ��2���)"
        [System.Threading.Thread]::Sleep(2000)
        if($WApi::FindWindow("ThunderRT6MDIForm","������ϰ�����_V2.0") -eq 0) {
            $isMain = $false
        }
    }
    Clear-Host
}

function WaitForModeUI {
    $isMain = $true
    if($WApi::FindWindow("ThunderRT6MDIForm","������ϰ�����_V2.0") -eq 0) {
        $isMain = $false
    }
    while ($isMain) {
        $Status.Text = "����ô����������!(��һ�μ��2���)"
        [System.Threading.Thread]::Sleep(2000)
        if($WApi::FindWindow("ThunderRT6MDIForm","������ϰ�����_V2.0") -eq 0) {
            $isMain = $false
        }
    }
    Clear-Host
}

# ��ȡ���ı��򼰴���HWND
function GetHWND {
    $mode
    while($true){
        "ȫ���","��������","FSJL��ϰ","ADKJ��ϰ","GHRU��ϰ","TVYM��ϰ","ELC,��ϰ","BN��ϰ","WZO/��ϰ","QXP.��ϰ","���ּ�һ" | ForEach-Object {
            if(!($WApi::FindWindow("ThunderRT6MDIForm","������ϰ�����_V2.0 - ["+ $_ +"]")) -eq 0) {
                $mode = $_
                break
            }
        }
        if( IsNullOrEmpty($mode) ) {
            Write-Host "δ�Զ�������ģʽ�����ֶ�����ģʽ��س�(��ϣ������������ֱ�ӻس�):"
            $mode = (Read-Host)
        }
        if (-not (IsNullOrEmpty($mode)) ) {
            if(!($WApi::FindWindow("ThunderRT6MDIForm","������ϰ�����_V2.0 - ["+ $_ +"]")) -eq 0) {
                break
            } else {
                Write-Host "δ��⵽��ģʽ��������,�����Զ���������....."
                $mode = $null
            }
        }
    }
    $return = 0,0
    $return[0] = $temp = $WApi::FindWindow("ThunderRT6MDIForm","������ϰ�����_V2.0 - ["+ $mode +"]")
    $temp = $WApi::FindWindowEx($temp,0,"MDIClient",$null)
    $temp = $WApi::FindWindowEx($temp,0,"ThunderRT6FormDC",$mode)
    $return[1] = $WApi::FindWindowEx($temp,0,"RichTextWndClass",$null)
    if ($return[0] -eq 0 -or $return[1] -eq 0) {
        Write-Error "�޷����ģʽ"
    }
    return $return
        
}

function GetHWNDUI {
    $mode
    while($true){
        "ȫ���","��������","FSJL��ϰ","ADKJ��ϰ","GHRU��ϰ","TVYM��ϰ","ELC,��ϰ","BN��ϰ","WZO/��ϰ","QXP.��ϰ","���ּ�һ" | ForEach-Object {
            if(!($WApi::FindWindow("ThunderRT6MDIForm","������ϰ�����_V2.0 - ["+ $_ +"]")) -eq 0) {
                $mode = $_
                break
            }
        }
        if( IsNullOrEmpty($mode) ) {
            $mode = [Microsoft.VisualBasic.Interaction]::InputBox("��ʾ", "δ�Զ�������ģʽ�����ֶ�����ģʽ", "һ��������ϰ", -1, -1); 
            
        }
        if (-not (IsNullOrEmpty($mode)) ) {
            if(!($WApi::FindWindow("ThunderRT6MDIForm","������ϰ�����_V2.0 - ["+ $_ +"]")) -eq 0) {
                break
            } else {
                $Status.Text = "δ��⵽��ģʽ��������,�����Զ���������....."
                $mode = $null
            }
        }
    }
    $return = 0,0
    $return[0] = $temp = $WApi::FindWindow("ThunderRT6MDIForm","������ϰ�����_V2.0 - ["+ $mode +"]")
    $temp = $WApi::FindWindowEx($temp,0,"MDIClient",$null)
    $temp = $WApi::FindWindowEx($temp,0,"ThunderRT6FormDC",$mode)
    $return[1] = $WApi::FindWindowEx($temp,0,"RichTextWndClass",$null)
    if ($return[0] -eq 0 -or $return[1] -eq 0) {
        Write-Error "�޷����ģʽ"
    }
    return $return
        
}

function GetInnerText($HWNDs) {
    $word = New-Object System.Text.StringBuilder(3001)
    $null = $WApi::SendMessage($HWNDs[2],0x000D,3001,$word)
    # ��Ϊ��������ģʽ�����Ծ��Ƿ��·�
    if($mode -eq "��������") {
        while($true) {
            if($word.ToString() -eq "") {
                Write-Output "��⵽ģʽΪ�������ԣ����ڵȴ��Ծ�"
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
    # ��Ϊ��������ģʽ�����Ծ��Ƿ��·�
    if($mode -eq "��������") {
        while($true) {
            if($word.ToString() -eq "") {
                $Status.Text =  "��⵽ģʽΪ�������ԣ����ڵȴ��Ծ�"
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

# ���ñ���
[Console]::Title = "�������Powershell�� v1.4"

if($args.Length -gt 0 -and $args[0] -eq "-Console") {
	Clear-Host
    Write-Host "�˽ű�ֻ����ѧϰ�Լ�����,�ɱ��ű�������һ�к�����߽Բ�����!`r`n`r`nGUI�汾�Ѿ��������,�����ܻ��кܶ�bug,����ȥ�� -Console ����ǰ������`r`n�����������"
	$null = [Console]::ReadKey()
	Clear-Host
    WaitForWindow
    WaitForMode
    $HWNDs = GetHWND
    $Text = GetInnerText($HWNDs)


    # ��������
    Write-Host �ѻ�ȡ������:
    Write-Host $Text -ForegroundColor Green

    Write-Host "����Ŀ���ٶ�:"
    $l = [convert]::ToInt32([Console]::ReadLine())
    Write-Host "�Զ���ʼ? Y/N (Y) "
    $a = [Console]::ReadKey()
    Write-Host "`0"
    $timeout = 1000 / ($l / 60)
    Write-Host "���������ʼ,��Ҫֹͣ�ص��˴��ڲ���Ctrl+C"
    $null = [Console]::ReadKey()

    # ��ʼ��ʺ
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

    # ����
    Write-Host ��������˳�
    $temp = [Console]::ReadKey()
} else {
	Clear-Host
    [System.Windows.MessageBox]::Show("�˽ű�ֻ����ѧϰ�Լ�����,�ɱ��ű�������һ�к�����߽Բ�����!`r`n`r`n�Լ�����ȫ��bug,��������˷ǳ����bug�뿼����� -Console ������������̨��","����")
    # ����UI
    $reader=(New-Object System.Xml.XmlNodeReader $UI) 
    try{
        $Form = [Windows.Markup.XamlReader]::Load( $reader )
    }
    catch{
        Write-Host "�޷�����WPF��������ʾUI���뿼��ʹ�� -Console ��������̨�汾"
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
                    $btnStart.Content = "������"
                    $StatusID = 1
                    $btnStop.Content = "��ͣ"
                    if(!$Speed.Text -is [int]) {
                        [System.Windows.MessageBox]::Show("�ٶȲ������֣�����������!")
                        break
                    }
                    WaitForWindowUI
                    $Status.Text = "������..."
                    WaitForModeUI
                    $Status.Text = "������..."
                    $HWNDs = GetHWNDUI
                    $Status.Text = "������..."
                    $Words.Text = $Text = GetInnerTextUI($HWNDs)
                    $Status.Text = "������..."
                    $SpeedInt = [Convert]::ToInt32($Speed.Text)
                    $Tick = 1000 / ( $SpeedInt / 60)
                    # ��ʼ��ʺ
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
                    $Status.Text = "����"
                    $btnStart.Content = "��ʼ"
                    $btnStop.Content = "��ȡ����"
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
#                    $btnStart.Content = "����"
#                    $btnStop.Content = "ֹͣ"
#                    $Status.Text = "��ͣ��"
#                    $StatusID = 2
#               }
#                2 {
#                    Stop-Job $Job
#                    Remove-Job $Job
#                    $Job = $null
#                    $Status.Text = "����"
#                    $btnStart.Content = "��ʼ"
#                    $btnStop.Content = "��ȡ����"
#                    $StatusID = 0
#                }
#                Default {
#                
#                }
#            }
       })
    $Form.ShowDialog()
}