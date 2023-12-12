clc; clear all; close all;

% Manuel normalizasyon fonksiyonu
% Değerleri 0-1 arasına indirgemektedir.
normalize2 = @(I) (I-min(min(I)))/(max(max(I))-min(min(I)));

% Data klasöründeki tüm resimleri alma
location = 'Data\*';
ds = imageDatastore(location);

% Tank resmini okuma ve üzerinde bazı işlemler yapma
color_tank  = imread('tank2.jpg');
gray_tank  = rgb2gray(color_tank);
normalized_tank = processTank(gray_tank);

% Kaçıncı resimde olduğumuzu tutan sayaç
Resim = 0;

% Bu döngü Data klasöründeki resim sayısı kadar döner
while hasdata(ds) 
    Resim = Resim + 1;
    
    % Data klasöründe hangi resimde kaldıysa o resmi okuma ve üzerinde
    % bazı işlemler yapma
    color_image = read(ds) ;
    normalized_image = processImage(color_image);

    for i=1 : 3

        figure; imshow(color_image);hold on;
        
        if(i == 1)

            convolved = conv2(normalized_image, normalized_tank);

        elseif(i == 2)

            convolved = konvolusyon2d(normalized_image, normalized_tank);
        
        else

            normalized_tank = rot90(normalized_tank,2);
            convolved = xcorr2(normalized_image, normalized_tank);

        end


        % Tüm pixel değerlerini 0-1 arasında yapma
        result = normalize2(convolved);
        
        % En benzer bölgeyi bulma ve satır sütun indisini tutma
        [maximum,imax] = max(abs(result(:)));
        [max_row,max_col] = ind2sub(size(result),imax);
    
        % Tank resminin satır sütun sayısını tutma
        [rowtank,columntank] = size(gray_tank);
    
        % Resimde kaç tane kareleme işlemi yaptığını tutan sayaç
        Kare_Sayisi = 0;
    
        % Bu döngü belirli bir eşik değerin üstündeki benzemeleri bulana kadar
        % devam eder
        while(maximum > 0.82) 
            
            % Bulunan bölgeyi kare içine alma
            rectangle('Position', [max_col-columntank max_row-rowtank ...
            columntank rowtank], 'EdgeColor', [0.5 0 0], 'LineWidth', 3, ...
            'LineStyle', '-.');
            
            % Aynı bölgede birden fazla kare alma işlemi yapılmaması ve sonsuz
            % döngüye girilmemesi için kare alınan bölgedeki değerler 0
            % değerini alır
            rowaralik = ceil(rowtank/2);
            columnaralik = ceil(columntank/2);
        
            for i=max_row-rowaralik : max_row+rowaralik
                for j=max_col-columnaralik : max_col+columnaralik
        
                    if(i>=1 && j>=1)
                        result(i,j) = 0;
                    end
                end
            end
        
            [maximum,imax] = max(abs(result(:)));
            [max_row,max_col] = ind2sub(size(result),imax);
    
            Kare_Sayisi = Kare_Sayisi + 1; 
        end
    
        % Güncel bulunulan resimdeki kareleme sayısını Command Window'a yazma
        display(Resim);
        display(Kare_Sayisi);

    end  

end




% Bu fonksiyonda renkli resimde bazı iyileştirme işlemleri yapılır
function sonuc = processImage(color_image)
    
    gray_image = rgb2gray(color_image);
    double_image = im2double(gray_image);
    sonuc = normalize(double_image);

end


% Bu fonksiyonda griye dönüştürülmüş tank resminde bazı iyileştirme
% işlemleri yapılır
function sonuc = processTank(gray_tank)

    rotate_tank = rot90(gray_tank,2);
    double_tank = im2double(rotate_tank);
    sonuc = normalize(double_tank);

end



% Bu fonksiyon 2 boyutlu konvolüsyon işlemini gerçekleştirmektedir
function sonuc = konvolusyon2d(A, k) 
    [rowA,columnA] = size(A);
    [rowK,columnK] = size(k);
    rotated = rot90(k, 2);
    Rep = zeros(rowA + rowK*2-2, columnA + columnK*2-2);
    for x = rowK : rowK+rowA-1
        for y = columnK : columnK+rowA-1
            Rep(x,y) = A(x-rowK+1, y-columnK+1);
        end
    end
    sonuc = zeros(rowA+rowK-1,columnK+columnA-1);
    for x = 1 : rowA+rowK-1
        for y = 1 : columnK+columnA-1
            for i = 1 : rowK
                for j = 1 : columnK
                    sonuc(x, y) = sonuc(x, y) + (Rep(x+i-1, y+j-1) * rotated(i, j));
                end
            end
        end
    end
end

