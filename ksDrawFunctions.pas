{*******************************************************************************
*                                                                              *
*  ksDrawFunctions - control drawing functions for ksListView                  *
*                                                                              *
*  https://github.com/gmurt/KernowSoftwareFMX                                  *
*                                                                              *
*  Copyright 2015 Graham Murt                                                  *
*                                                                              *
*  email: graham@kernow-software.co.uk                                         *
*                                                                              *
*  Licensed under the Apache License, Version 2.0 (the "License");             *
*  you may not use this file except in compliance with the License.            *
*  You may obtain a copy of the License at                                     *
*                                                                              *
*    http://www.apache.org/licenses/LICENSE-2.0                                *
*                                                                              *
*  Unless required by applicable law or agreed to in writing, software         *
*  distributed under the License is distributed on an "AS IS" BASIS,           *
*  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    *
*  See the License for the specific language governing permissions and         *
*  limitations under the License.                                              *
*                                                                              *
*******************************************************************************}

unit ksDrawFunctions;

interface

uses Classes, FMX.Graphics, FMX.Types, Types, System.UIConsts, System.UITypes,
  FMX.ListView.Types, FMX.Platform;

type
  TksButtonStyle = (ksButtonDefault, ksButtonSegmentLeft, ksButtonSegmentMiddle, ksButtonSegmentRight);

  function GetScreenScale: single;

  function IsBlankBitmap(ABmp: TBitmap): Boolean;

  procedure DrawSwitch(ACanvas: TCanvas; ARect: TRectF; AChecked: Boolean);
  procedure DrawButton(ACanvas: TCanvas; ARect: TRectF; AText: string; ASelected: Boolean; AColor: TAlphaColor; AStyle: TksButtonStyle);

  procedure DrawAccessory(ACanvas: TCanvas; ARect: TRectF; AColor: TAlphaColor; AAccessory: TAccessoryType);
  procedure DrawCheckMarkAccessory(ACanvas: TCanvas; ARect: TRectF; AColor: TAlphaColor);
  procedure DrawMoreAccessory(ACanvas: TCanvas; ARect: TRectF; AColor: TAlphaColor);



implementation

var
  _ScreenScale: single;


function GetScreenScale: single;
var
  Service: IFMXScreenService;
begin
  if _ScreenScale > 0 then
  begin
    Result := _ScreenScale;
    Exit;
  end;
  Service := IFMXScreenService(TPlatformServices.Current.GetPlatformService
    (IFMXScreenService));
  Result := Service.GetScreenScale;
  {$IFDEF MSWINDOWS}
  if Result < 2 then
    Result := 2;
  {$ENDIF}
  _ScreenScale := Result;

end;

function IsBlankBitmap(ABmp: TBitmap): Boolean;
var
  ABlank: TBitmap;
begin
  ABlank := TBitmap.Create(ABmp.Width, ABmp.Height);
  try
    ABlank.Clear(claNull);
    Result := ABmp.EqualsBitmap(ABlank);
  finally
    {$IFDEF IOS}
    ABlank.DisposeOf;
    {$ELSE}
    ABlank.Free;
    {$ENDIF}
  end;
end;



procedure DrawSwitch(ACanvas: TCanvas; ARect: TRectF; AChecked: Boolean);
var
  ABmp: TBitmap;
  r: TRectF;
  ASwitchRect: TRectF;
begin
  ABmp := TBitmap.Create(Round(ARect.Width * GetScreenScale), Round(ARect.Height * GetScreenScale));
  try
    ABmp.Clear(claNull);
    ABmp.BitmapScale := GetScreenScale;

    ABmp.Canvas.BeginScene;
    ABmp.Canvas.StrokeThickness := GetScreenScale;

    r := RectF(0, 0, ABmp.Height, ABmp.Height);
    if not AChecked then
      ASwitchRect := r;
    ABmp.Canvas.Stroke.Color := claSilver;
    ABmp.Canvas.Fill.Color := claWhite;
    if AChecked then
      Abmp.Canvas.Fill.Color := claYellowgreen;

    ABmp.Canvas.FillEllipse(r, 1, ABmp.Canvas.Fill);
    ABmp.Canvas.DrawEllipse(r, 1, ABmp.Canvas.Stroke);
    OffsetRect(r, ABmp.Width-r.Height, 0);
    if AChecked then
      ASwitchRect := r;

    ABmp.Canvas.FillEllipse(r, 1, ABmp.Canvas.Fill);
    ABmp.Canvas.DrawEllipse(r, 1, ABmp.Canvas.Stroke);

    //ABmp.Canvas.Fill.Color := claWhite;
    ABmp.Canvas.FillRect(RectF(0  + (r.Width/2), 0, ABmp.Width - (r.Width/2), ABmp.Height), 0, 0,  AllCorners, 1, ABmp.Canvas.Fill);

    r := RectF(ABmp.Height/2, 0, ABmp.Width-(ABmp.Height/2), ABmp.Height);


    ABmp.Canvas.FillRect(r, 0, 0, AllCorners, 1, ABmp.Canvas.Fill);
    ABmp.Canvas.StrokeThickness := 3;
    r.Bottom := r.Bottom -1;
    r.Left := r.Left - (GetScreenScale*4);
    r.Right := r.Right + (GetScreenScale*4);
    ABmp.Canvas.DrawRectSides(r, 0, 0, AllCorners, 1, [TSide.Top, TSide.Bottom], ABmp.Canvas.Stroke);
    ABmp.Canvas.StrokeThickness := 2;

    ABmp.Canvas.Fill.Color := claWhite;

    if AChecked then
    begin
      InflateRect(ASwitchRect, -2, -2);
      ABmp.Canvas.FillEllipse(ASwitchRect, 1, ABmp.Canvas.Fill);
    end
    else
    begin
      InflateRect(ASwitchRect, -1, -1);
      ABmp.Canvas.Stroke.Color := claSilver;
      ABmp.Canvas.DrawEllipse(ASwitchRect, 1, ABmp.Canvas.Stroke);
    end;
    ABmp.Canvas.EndScene;
    ACanvas.DrawBitmap(ABmp, RectF(0, 0, ABmp.Width, ABmp.Height), ARect, 1, False);
  finally
    {$IFDEF IOS}
    ABmp.DisposeOf;
    {$ELSE}
    ABmp.Free;
    {$ENDIF};
  end;
end;

procedure DrawButton(ACanvas: TCanvas; ARect: TRectF; AText: string; ASelected: Boolean; AColor: TAlphaColor; AStyle: TksButtonStyle);
var
  ABmp: TBitmap;
  r: TRectF;
  ARadius: single;
  AFill, AOutline, AFontColor: TAlphaColor;
begin
  ARadius := 5*GetScreenScale;
  //ACanvas.FillEllipse(ARect, 1, ACanvas.Fill);
  ABmp := TBitmap.Create(Round(ARect.Width * GetScreenScale), Round(ARect.Height * GetScreenScale));
  try
    if AColor = claNull then
      AColor := claBlue;

    ABmp.Clear(claNull);
    ABmp.BitmapScale := GetScreenScale;
    r := RectF(0, 0, ABmp.Width, ABmp.Height);
    ABmp.Canvas.BeginScene;
    ABmp.Canvas.StrokeThickness := GetScreenScale;
    ABmp.Canvas.Stroke.Color := claSilver;
    ABmp.Canvas.Font.Size := (13 * GetScreenScale);
    //ABmp.Canvas.FillEllipse(RectF(0, 0, ABmp.Width, ABmp.Height), 1, ACanvas.Fill);

    if ASelected then
    begin
      AFill := AColor;
      AOutline := AColor;
      AFontColor := claWhite;
    end
    else
    begin
      AFill := claWhite;
      AOutline := AColor;
      AFontColor := AColor;
    end;
    ABmp.Canvas.Blending := True;
    ABmp.Canvas.Fill.Color := AFill;
    ABmp.Canvas.Stroke.Color := AOutline;
    if AStyle = ksButtonSegmentLeft then
    begin
      ABmp.Canvas.FillRect(r, ARadius, ARadius, [TCorner.TopLeft, TCorner.BottomLeft], 1, ABmp.Canvas.Fill);
      ABmp.Canvas.DrawRect(r, ARadius, ARadius, [TCorner.TopLeft, TCorner.BottomLeft], 1, ABmp.Canvas.Stroke);
    end
    else
    if AStyle = ksButtonSegmentRight then
    begin
      ABmp.Canvas.FillRect(r, ARadius, ARadius, [TCorner.TopRight, TCorner.BottomRight], 1, ABmp.Canvas.Fill);
      ABmp.Canvas.DrawRect(r, ARadius, ARadius, [TCorner.TopRight, TCorner.BottomRight], 1, ABmp.Canvas.Stroke);
    end
    else
    begin
      ABmp.Canvas.FillRect(r, 0, 0, AllCorners, 1, ABmp.Canvas.Fill);
      ABmp.Canvas.DrawRect(r, 0, 0, AllCorners, 1, ABmp.Canvas.Stroke);
    end;

    ABmp.Canvas.Fill.Color := AFontColor;
    ABmp.Canvas.FillText(r, AText, False, 1, [], TTextAlign.Center);


    //ABmp.Canvas.DrawRect(RectF(0, 0, ABmp.Width, ABmp.Height), 0, 0, AllCorners, 1, ACanvas.Stroke);
    ABmp.Canvas.EndScene;

    ACanvas.DrawBitmap(ABmp, RectF(0, 0, ABmp.Width, ABmp.Height), ARect, 1, False);
  finally
    {$IFDEF IOS}
    ABmp.DisposeOf;
    {$ELSE}
    ABmp.Free;
    {$ENDIF}
  end;
end;

procedure DrawAccessory(ACanvas: TCanvas; ARect: TRectF; AColor: TAlphaColor; AAccessory: TAccessoryType);
begin
  case AAccessory of

    TAccessoryType.More:      DrawMoreAccessory(ACanvas, ARect, AColor);
    TAccessoryType.Checkmark: DrawCheckMarkAccessory(ACanvas, ARect, AColor) ;
    TAccessoryType.Detail: ;
  end;
end;

procedure DrawCheckMarkAccessory(ACanvas: TCanvas; ARect: TRectF; AColor: TAlphaColor);
var
  ABmp: TBitmap;
  r: TRectF;
begin
  ABmp := TBitmap.Create(Round(ARect.Width * GetScreenScale), Round(ARect.Height * GetScreenScale));
  try
    ABmp.Clear(claNull);
    ABmp.BitmapScale := GetScreenScale;

    ABmp.Canvas.BeginScene;
    ABmp.Canvas.StrokeThickness := 2*GetScreenScale;
    ABmp.Canvas.Stroke.Color := AColor;
    r := RectF(0, 0, ABmp.Height, ABmp.Height);

    ABmp.Canvas.DrawLine(PointF(4, ABmp.Height/2), PointF(ABmp.Width/3, ABmp.Height-4), 1);
    ABmp.Canvas.DrawLine(PointF(ABmp.Width/3, ABmp.Height-4), PointF(ABmp.Width-4, 0),  1);

    ABmp.Canvas.EndScene;



    //AAccessoryCheck.Assign(ABmp);
    ACanvas.DrawBitmap(ABmp, RectF(0, 0, ABmp.Width, ABmp.Height), ARect, 1, False);
  finally
    {$IFDEF IOS}
    ABmp.DisposeOf;
    {$ELSE}
    ABmp.Free;
    {$ENDIF}
  end;
end;

procedure DrawMoreAccessory(ACanvas: TCanvas; ARect: TRectF; AColor: TAlphaColor);
var
  ABmp: TBitmap;
  APath: TPathData;
  APadding: single;
begin
  ABmp := TBitmap.Create(Round(ARect.Width * GetScreenScale), Round(ARect.Height * GetScreenScale));
  try
    ABmp.Clear(claNull);
    ABmp.BitmapScale := GetScreenScale;

    ABmp.Canvas.BeginScene;
    ABmp.Canvas.StrokeThickness := GetScreenScale*2;
    ABmp.Canvas.Stroke.Color := AColor;
    ABmp.Canvas.StrokeJoin := TStrokeJoin.Miter;

    APadding := GetScreenScale;

    APath := TPathData.Create;
    try
      APath.MoveTo(PointF(ABmp.Width / 2, ABmp.Height-APadding));
      APath.LineTo(PointF(ABmp.Width-APadding, (ABmp.Height/2)));
      APath.LineTo(PointF(ABmp.Width / 2, APadding));
      APath.MoveTo(PointF(ABmp.Width-APadding, (ABmp.Height/2)));
      APath.ClosePath;

      ABmp.Canvas.DrawPath(APath, 1);
    finally
      {$IFDEF IOS}
      APath.DisposeOf;
      {$ELSE}
      APath.Free;
      {$ENDIF}
    end;

    ABmp.Canvas.EndScene;



    ACanvas.DrawBitmap(ABmp, RectF(0, 0, ABmp.Width, ABmp.Height), ARect, 1, False);
  finally
    {$IFDEF IOS}
    ABmp.DisposeOf;
    {$ELSE}
    ABmp.Free;
    {$ENDIF}
  end;
end;

initialization

  _ScreenScale := 0;



end.