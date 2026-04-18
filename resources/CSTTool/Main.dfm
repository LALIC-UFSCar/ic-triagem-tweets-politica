object MainForm: TMainForm
  Left = 227
  Top = 151
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'CSTTool'
  ClientHeight = 564
  ClientWidth = 854
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object TabbedNotebook1: TTabbedNotebook
    Left = 0
    Top = 0
    Width = 854
    Height = 564
    Align = alClient
    PageIndex = 1
    TabFont.Charset = DEFAULT_CHARSET
    TabFont.Color = clBtnText
    TabFont.Height = -11
    TabFont.Name = 'MS Sans Serif'
    TabFont.Style = []
    TabOrder = 0
    object TTabPage
      Left = 4
      Top = 24
      Caption = 'Text Segmentation'
      object Label8: TLabel
        Left = 8
        Top = 16
        Width = 761
        Height = 13
        Caption = 
          'You may choose to segment the text automatically or not. If you ' +
          'decide to do it automatically, you may still revise/correct it i' +
          'n the text box for manual segmentation.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object GroupBox2: TGroupBox
        Left = 8
        Top = 48
        Width = 833
        Height = 97
        Caption = ' Automatic segmentation '
        TabOrder = 0
        object Label1: TLabel
          Left = 16
          Top = 24
          Width = 165
          Height = 13
          Caption = 'Select the file you want to segment'
        end
        object Edit1: TEdit
          Left = 16
          Top = 40
          Width = 721
          Height = 21
          TabOrder = 0
        end
        object Button1: TButton
          Left = 742
          Top = 38
          Width = 75
          Height = 25
          Caption = 'Open'
          TabOrder = 1
          OnClick = Button1Click
        end
        object Button2: TButton
          Left = 372
          Top = 64
          Width = 89
          Height = 25
          Caption = 'Segment file'
          TabOrder = 2
          OnClick = Button2Click
        end
      end
      object GroupBox3: TGroupBox
        Left = 8
        Top = 152
        Width = 833
        Height = 377
        Caption = ' Manual segmentation '
        TabOrder = 1
        object Label4: TLabel
          Left = 16
          Top = 24
          Width = 331
          Height = 13
          Caption = 
            'Text you want to segment (put one sentence per line for segmenti' +
            'ng it)'
        end
        object Memo3: TMemo
          Left = 16
          Top = 40
          Width = 801
          Height = 297
          ScrollBars = ssVertical
          TabOrder = 0
        end
        object Button7: TButton
          Left = 16
          Top = 344
          Width = 75
          Height = 25
          Caption = 'Open text'
          TabOrder = 1
          OnClick = Button7Click
        end
        object Button8: TButton
          Left = 96
          Top = 344
          Width = 129
          Height = 25
          Caption = 'Save segmented text'
          TabOrder = 2
          OnClick = Button8Click
        end
        object Button9: TButton
          Left = 742
          Top = 344
          Width = 75
          Height = 25
          Caption = 'Clear'
          TabOrder = 4
          OnClick = Button9Click
        end
        object Button10: TButton
          Left = 630
          Top = 344
          Width = 107
          Height = 25
          Caption = 'Do not wrap lines'
          TabOrder = 3
          OnClick = Button10Click
        end
      end
    end
    object TTabPage
      Left = 4
      Top = 24
      Caption = 'CST Structuring'
      object Label2: TLabel
        Left = 8
        Top = 56
        Width = 30
        Height = 13
        Caption = 'Text 1'
      end
      object Label3: TLabel
        Left = 432
        Top = 56
        Width = 30
        Height = 13
        Caption = 'Text 2'
      end
      object Label9: TLabel
        Left = 8
        Top = 16
        Width = 778
        Height = 13
        Caption = 
          'Open the texts (already segmented) that you want to analyze and ' +
          'put the relations among their segments using the box in the bott' +
          'om. Do not forget to identify yourself.'
      end
      object Memo1: TMemo
        Left = 8
        Top = 72
        Width = 409
        Height = 249
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 3
      end
      object Memo2: TMemo
        Left = 432
        Top = 72
        Width = 409
        Height = 249
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 7
      end
      object GroupBox1: TGroupBox
        Left = 8
        Top = 328
        Width = 833
        Height = 201
        Caption = 
          ' Select relations and their directionality among the segment pai' +
          'rs that you judge appropriate (you do not need to put relations ' +
          'among all segment pairs) '
        TabOrder = 8
        object Label5: TLabel
          Left = 96
          Top = 24
          Width = 67
          Height = 13
          Caption = 'Segment pairs'
        end
        object Label7: TLabel
          Left = 288
          Top = 24
          Width = 58
          Height = 13
          Caption = 'CST relation'
        end
        object Label10: TLabel
          Left = 576
          Top = 24
          Width = 59
          Height = 13
          Caption = 'New relation'
        end
        object Label11: TLabel
          Left = 16
          Top = 72
          Width = 365
          Height = 13
          Caption = 
            'Relations that you included (you may also edit this text box dir' +
            'ectly if you wish)'
        end
        object Label12: TLabel
          Left = 400
          Top = 24
          Width = 60
          Height = 13
          Caption = 'Directionality'
        end
        object Label13: TLabel
          Left = 744
          Top = 24
          Width = 51
          Height = 13
          Caption = 'Your name'
        end
        object Label6: TLabel
          Left = 16
          Top = 24
          Width = 47
          Height = 13
          Caption = 'Threshold'
        end
        object ComboBox1: TComboBox
          Left = 96
          Top = 40
          Width = 185
          Height = 21
          ItemHeight = 13
          TabOrder = 0
        end
        object ComboBox3: TComboBox
          Left = 288
          Top = 40
          Width = 105
          Height = 21
          ItemHeight = 13
          TabOrder = 1
        end
        object Button11: TButton
          Left = 656
          Top = 38
          Width = 41
          Height = 25
          Caption = 'Add'
          TabOrder = 5
          OnClick = Button11Click
        end
        object Edit2: TEdit
          Left = 576
          Top = 40
          Width = 73
          Height = 21
          Color = cl3DLight
          TabOrder = 4
        end
        object BitBtn1: TBitBtn
          Left = 472
          Top = 38
          Width = 73
          Height = 25
          Caption = 'Include'
          TabOrder = 3
          OnClick = BitBtn1Click
          Glyph.Data = {
            76010000424D7601000000000000760000002800000020000000100000000100
            04000000000000010000120B0000120B00001000000000000000000000000000
            800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333303333
            333333333337F33333333333333033333333333333373F333333333333090333
            33333333337F7F33333333333309033333333333337373F33333333330999033
            3333333337F337F33333333330999033333333333733373F3333333309999903
            333333337F33337F33333333099999033333333373333373F333333099999990
            33333337FFFF3FF7F33333300009000033333337777F77773333333333090333
            33333333337F7F33333333333309033333333333337F7F333333333333090333
            33333333337F7F33333333333309033333333333337F7F333333333333090333
            33333333337F7F33333333333300033333333333337773333333}
          Layout = blGlyphRight
          NumGlyphs = 2
        end
        object Memo4: TMemo
          Left = 16
          Top = 88
          Width = 737
          Height = 105
          ScrollBars = ssBoth
          TabOrder = 7
          OnChange = Memo4Change
        end
        object Button14: TButton
          Left = 760
          Top = 88
          Width = 59
          Height = 25
          Caption = 'Open'
          TabOrder = 8
          OnClick = Button14Click
        end
        object Button12: TButton
          Left = 760
          Top = 128
          Width = 59
          Height = 25
          Caption = 'Save'
          TabOrder = 9
          OnClick = Button12Click
        end
        object Button13: TButton
          Left = 760
          Top = 168
          Width = 59
          Height = 25
          Caption = 'Clear'
          TabOrder = 10
          OnClick = Button13Click
        end
        object ComboBox4: TComboBox
          Left = 400
          Top = 40
          Width = 65
          Height = 21
          ItemHeight = 13
          TabOrder = 2
          Items.Strings = (
            'None'
            '-->'
            '<--')
        end
        object Edit3: TEdit
          Left = 736
          Top = 40
          Width = 81
          Height = 21
          Color = clAqua
          TabOrder = 6
          OnChange = Edit3Change
        end
        object Edit6: TEdit
          Left = 16
          Top = 40
          Width = 49
          Height = 21
          Color = cl3DLight
          TabOrder = 11
          Text = '0,12'
          OnExit = Edit6Exit
        end
      end
      object Button3: TButton
        Left = 280
        Top = 48
        Width = 75
        Height = 22
        Caption = 'Open Text 1'
        TabOrder = 1
        OnClick = Button3Click
      end
      object Button4: TButton
        Left = 704
        Top = 48
        Width = 75
        Height = 22
        Caption = 'Open Text 2'
        TabOrder = 5
        OnClick = Button4Click
      end
      object Button5: TButton
        Left = 360
        Top = 48
        Width = 57
        Height = 22
        Caption = 'Clear'
        TabOrder = 2
        OnClick = Button5Click
      end
      object Button6: TButton
        Left = 784
        Top = 48
        Width = 57
        Height = 22
        Caption = 'Clear'
        TabOrder = 6
        OnClick = Button6Click
      end
      object Edit4: TEdit
        Left = 48
        Top = 48
        Width = 217
        Height = 21
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 0
      end
      object Edit5: TEdit
        Left = 472
        Top = 48
        Width = 217
        Height = 21
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 4
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = '*.txt|*.txt|*.*|*.*'
    Left = 752
    Top = 32
  end
  object OpenDialog2: TOpenDialog
    Filter = '*.seg|*.seg|*.txt|*.txt|*.*|*.*'
    Left = 784
    Top = 32
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'seg'
    Filter = '*.seg|*.seg|*.txt|*.txt|*.*|*.*'
    Left = 688
    Top = 32
  end
  object SaveDialog2: TSaveDialog
    DefaultExt = 'cst'
    Filter = '*.cst|*.cst|*.*|*.*'
    Left = 720
    Top = 32
  end
  object OpenDialog3: TOpenDialog
    Filter = '*.cst|*.cst|*.*|*.*'
    Left = 816
    Top = 32
  end
end
