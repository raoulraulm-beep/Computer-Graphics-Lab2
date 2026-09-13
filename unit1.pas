unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, ExtDlgs, StdCtrls, LCLIntf, math;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    OpenPictureDialog1: TOpenPictureDialog;
    Panel1: TPanel;
    SavePictureDialog1: TSavePictureDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Edit6Change(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Edit6Change(Sender: TObject);
begin

end;
function ConvertTo24Bit(aValue: TBitmap; BackColor: TColor): TBitmap;
begin
  Result := TBitmap.Create;
  with Result do
  begin
    if aValue.PixelFormat <> pf24bit then
    begin
      PixelFormat := pf24bit;
      SetSize(aValue.Width, aValue.Height);
      Canvas.FloodFill(0, 0, BackColor, fsBorder);
      Canvas.Draw(0, 0, aValue);
    end
    else
      Assign(aValue);
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  W, H: Integer;
begin
  // 1. Read dimensions from the first two Edit boxes (default to 600x500 if empty)
  W := StrToIntDef(Edit1.Text, 600);
  H := StrToIntDef(Edit2.Text, 500);

  // 2. Initialize the Bitmap for Image1
  Image1.Picture.Bitmap.PixelFormat := pf24bit;
  Image1.Picture.Bitmap.Width := W;
  Image1.Picture.Bitmap.Height := H;

  // 3. Fill the surface with a solid white color
  Image1.Picture.Bitmap.Canvas.Brush.Color := clWhite;
  Image1.Picture.Bitmap.Canvas.Brush.Style := bsSolid;
  Image1.Picture.Bitmap.Canvas.FillRect(Rect(0, 0, W, H));
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  // Execute the file dialog to pick an image from the computer
  if OpenPictureDialog1.Execute then
  begin
    // Load the selected image into Image2 (right panel)
    Image2.Picture.LoadFromFile(OpenPictureDialog1.FileName);

    // Enable automated resizing inside the Image component frame
    Image2.Stretch := True;
    Image2.Proportional := True;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  x1, y1, R, x2, y2: Integer;
  px, py: Integer;
  Dist: Double;
  PixelColor: TColor; // Renommé ici pour éviter le conflit avec Forms
begin
  // 1. Read coordinates from your interface TEdit boxes
  x1 := StrToIntDef(Edit3.Text, 90);  // Destination X (Center of circle on white page)
  y1 := StrToIntDef(Edit4.Text, 90);  // Destination Y (Center of circle on white page)
  R  := StrToIntDef(Edit5.Text, 80);  // Radius of the circle
  x2 := StrToIntDef(Edit6.Text, 320); // Source X (Center of photo)
  y2 := StrToIntDef(Edit7.Text, 180); // Source Y (Center of photo)

  // 2. Scan and copy pixel by pixel using the equation of a circle
  for py := -R to R do
  begin
    for px := -R to R do
    begin
      // Mathematical distance from the center of the circle
      Dist := Sqrt(px*px + py*py);

      // If the pixel is inside the circular boundary (Distance <= Radius)
      if Dist <= R then
      begin
        // Read color from the center of Image2 (Source photo)
        PixelColor := Image2.Picture.Bitmap.Canvas.Pixels[x2 + px, y2 + py];

        // Paste it in the top-left corner area of Image1 (Destination canvas)
        Image1.Picture.Bitmap.Canvas.Pixels[x1 + px, y1 + py] := PixelColor;
      end;
    end;
  end;

  // 3. Draw a thin black decorative border around the circle
  Image1.Picture.Bitmap.Canvas.Pen.Color := clBlack;
  Image1.Picture.Bitmap.Canvas.Pen.Width := 1;
  Image1.Picture.Bitmap.Canvas.Brush.Style := bsClear;
  Image1.Picture.Bitmap.Canvas.Ellipse(x1 - R, y1 - R, x1 + R, y1 + R);

  // Refresh the display frame
  Image1.Invalidate;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  W, H: Integer;
  cx, cy: Integer; // Center coordinates (Mathematical origin 0,0)
  i: Integer;
  Step: Integer;   // Distance between two tick marks in pixels
begin
  // Safety check: verify that Image1 is initialized
  if Image1.Picture.Bitmap.Empty then
  begin
    ShowMessage('Please create Image1 first!');
    Exit;
  end;

  W := Image1.Picture.Bitmap.Width;
  H := Image1.Picture.Bitmap.Height;

  // Position the origin (0,0) lower and centered
  // to avoid overlapping with the circular fragment in the top-left corner
  cx := W div 2;
  cy := (H * 3) div 4;

  with Image1.Picture.Bitmap.Canvas do
  begin
    // 1. Setup the drawing pen (Solid black line, width 2)
    Pen.Color := clBlack;
    Pen.Width := 2;
    Pen.Style := psSolid;

    // 2. DRAW X-AXE (Horizontal)
    MoveTo(10, cy);
    LineTo(W - 10, cy);

    // Draw the arrow head for X-axe
    MoveTo(W - 10, cy); LineTo(W - 20, cy - 5);
    MoveTo(W - 10, cy); LineTo(W - 20, cy + 5);

    // 3. DRAW Y-AXE (Vertical)
    MoveTo(cx, 10);
    LineTo(cx, H - 10);

    // Draw the arrow head for Y-axe
    MoveTo(cx, 10); LineTo(cx - 5, 20);
    MoveTo(cx, 10); LineTo(cx + 5, 20);

    // 4. DRAW GRADUATIONS AND LABELS
    Step := 40; // 40 pixels corresponds to 1 mathematical unit
    Pen.Width := 1; // Thinner pen for tick marks
    Font.Name := 'Arial';
    Font.Size := 8;
    Font.Color := clBlack;

    // Axis labels
    TextOut(W - 25, cy - 20, 'X');
    TextOut(cx + 10, 10, 'Y');
    TextOut(cx - 15, cy + 5, '0'); // Origin label

    // Draw grid graduations along the X-axe (Right and Left directions)
    for i := 1 to (W div Step) do
    begin
      // Positive scale (Right)
      if cx + i * Step < W - 20 then
      begin
        MoveTo(cx + i * Step, cy - 4); LineTo(cx + i * Step, cy + 4);
        TextOut(cx + i * Step - 5, cy + 8, IntToStr(i));
      end;
      // Negative scale (Left)
      if cx - i * Step > 10 then
      begin
        MoveTo(cx - i * Step, cy - 4); LineTo(cx - i * Step, cy + 4);
        TextOut(cx - i * Step - 8, cy + 8,  '-' + IntToStr(i));
      end;
    end;

    // Draw grid graduations along the Y-axe (Up and Down directions)
    for i := 1 to (H div Step) do
    begin
      // Positive scale (Upwards in mathematics = subtraction in pixel coordinates)
      if cy - i * Step > 20 then
      begin
        MoveTo(cx - 4, cy - i * Step); LineTo(cx + 4, cy - i * Step);
        TextOut(cx - 20, cy - i * Step - 6, IntToStr(i));
      end;
      // Negative scale (Downwards in mathematics = addition in pixel coordinates)
      if cy + i * Step < H - 10 then
      begin
        MoveTo(cx - 4, cy + i * Step); LineTo(cx + 4, cy + i * Step);
        TextOut(cx - 25, cy + i * Step - 6, '-' + IntToStr(i));
      end;
    end;
  end;

  // Force the display frame to update visually
  Image1.Invalidate;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  W, H: Integer;
  cx, cy: Integer;     // Mathematical origin (0,0) matching Button4
  Step: Integer;       // 40 pixels = 1 unit matching Button4
  PixelX, PixelY: Integer;
  MathX, MathY: Double;
  FirstPoint: Boolean;
  LabelText: String;
begin
  // Safety check: verify that Image1 is initialized
  if Image1.Picture.Bitmap.Empty then
  begin
    ShowMessage('Please create Image1 first!');
    Exit;
  end;

  W := Image1.Picture.Bitmap.Width;
  H := Image1.Picture.Bitmap.Height;

  // Origin coordinates must be RIGIDLY identical to Button4Click
  cx := W div 2;
  cy := (H * 3) div 4;
  Step := 40;

  with Image1.Picture.Bitmap.Canvas do
  begin
    // --- NEW: WRITE THE FUNCTION FORMULA IN THE TOP-RIGHT CORNER ---
    Font.Name := 'Arial';
    Font.Size := 12;         // Slightly larger text for the title
    Font.Style := [fsBold];  // Make it bold so it stands out
    Font.Color := clBlue;    // Matching the curve color

    LabelText := 'y = x^(1/3)';
    // We position it at (Width - 120 pixels) to safely sit in the top-right corner
    TextOut(W - 120, 15, LabelText);

    // --- DRAW THE CURVE FUNCTION ---
    Pen.Color := clBlue;
    Pen.Width := 3;
    Pen.Style := psSolid;

    FirstPoint := True;

    // Scan through every horizontal pixel column from left to right
    for PixelX := 10 to W - 10 do
    begin
      // 1. Convert pixel coordinate to mathematical X value
      MathX := (PixelX - cx) / Step;

      // 2. Calculate the Cubic Root (y = x^(1/3)) supporting negative bases
      if MathX > 0 then
        MathY := Power(MathX, 1.0 / 3.0)
      else if MathX < 0 then
        MathY := -Power(Abs(MathX), 1.0 / 3.0)
      else
        MathY := 0;

      // 3. Convert mathematical Y value back to pixel coordinate
      PixelY := cy - Round(MathY * Step);

      // 4. Draw the curve segments onto the canvas
      if (PixelY >= 10) and (PixelY <= H - 10) then
      begin
        if FirstPoint then
        begin
          MoveTo(PixelX, PixelY);
          FirstPoint := False;
        end
        else
          LineTo(PixelX, PixelY);
      end
      else
        FirstPoint := True; // Break the line if it goes off-screen
    end;
  end;

  // Refresh the display frame
  Image1.Invalidate;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  // Set the file filter for standard image formats
  SavePictureDialog1.Filter := 'PNG Image (*.png)|*.png|Bitmap Image (*.bmp)|*.bmp';

  // If the user selects a location, names the file, and clicks Save
  if SavePictureDialog1.Execute then
  begin
    // Save the finalized contents of Image1 to the disk
    Image1.Picture.SaveToFile(SavePictureDialog1.FileName);
    ShowMessage('Your graphic report image has been successfully saved!');
  end;
end;

procedure TForm1.Button7Click(Sender: TObject);
var
  TxtFile: TextFile;
  px, py: Integer;
  Gray: Byte;
  BinaryValue: Char;
  CurrentColor: TColor;
begin
  // Safety check: verify that Image1 contains a generated drawing
  if (Image1.Picture.Bitmap.Empty) then
  begin
    ShowMessage('Please generate the graphic report first!');
    Exit;
  end;

  // Set the save file dialog filter specifically for PBM files
  SavePictureDialog1.Filter := 'Portable Bitmap (*.pbm)|*.pbm';

  if SavePictureDialog1.Execute then
  begin
    // Link the file variable to the chosen filename and open it for writing
    AssignFile(TxtFile, SavePictureDialog1.FileName);
    Rewrite(TxtFile);

    // Write the PBM ASCII header (P1 format: Plain Black and White)
    Writeln(TxtFile, 'P1');
    Writeln(TxtFile, IntToStr(Image1.Picture.Bitmap.Width) + ' ' + IntToStr(Image1.Picture.Bitmap.Height));

    // Process each pixel of the combined result row by row
    with Image1.Picture.Bitmap do
    begin
      for py := 0 to Height - 1 do
      begin
        for px := 0 to Width - 1 do
        begin
          // Get the color data of the current pixel (photo fragment, axes, or blue line)
          CurrentColor := Canvas.Pixels[px, py];

          // Calculate perceived brightness (Grayscale formula)
          Gray := Round(0.299 * GetRValue(CurrentColor) +
                        0.587 * GetGValue(CurrentColor) +
                        0.114 * GetBValue(CurrentColor));

          // Thresholding at 127: In standard ASCII PBM, '0' is white and '1' is black
          if Gray > 127 then
            BinaryValue := '0'
          else
            BinaryValue := '1';

          // Write the binary digit followed by a separating space
          Write(TxtFile, BinaryValue + ' ');
        end;
        Writeln(TxtFile); // Move to a new line at the end of each row
      end;
    end;

    // Close the file stream cleanly
    CloseFile(TxtFile);
    ShowMessage('Combined graphic exported to PBM text file successfully!');
  end;
end;

end.

