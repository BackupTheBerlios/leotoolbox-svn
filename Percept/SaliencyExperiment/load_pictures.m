function[pictures] = load_bitmaps
%
%  loads all stimuli images from the preset directory
%
%  J.B.C. Marsman, 
%
%  7 - 12 - 2006
%
%  Neuroimaging Center
%  Behavioural and Cognitive Neurosciences
%  University Medical Center Groningen
% 

%  Revision history :
%
%  6/12/2006    Created


fprintf('Loading image database\n');
fprintf('One moment please...\n');

resizeTo = [];
resizeTo = [100 100];

max_bitmap= 10;

bitmap_path = '/Users/justvanes/Documents/JanBernard/SaliencyExperiment/stimuli/';
files = dir(bitmap_path);


index = 1;
pictures = picture;

for f = 1:size(files, 1)
     if isImage( [bitmap_path files(f).name])
        bitmap_filename = [ bitmap_path files(f).name ];
        current_bitmap = bitmap;
        current_bitmap = set(current_bitmap, 'filename', bitmap_filename);
    
        try
          if (~isempty(resizeTo))
              % perform bitmap resize to the size size on the fly
              current_bitmap = set(current_bitmap, 'data', imresize(imread(bitmap_filename), resizeTo, 'bilinear'));

          else
              current_bitmap = set(current_bitmap, 'data', imread(bitmap_filename));
          end;
          
        catch
          fprintf('Error occurred while reading :\n');
          fprintf('Filename : %s\n', bitmap_filename);
        end;
        fprintf('%d..', index);
        current_bitmap = set(current_bitmap, 'name', files(f).name);
        current_bitmap = set(current_bitmap, 'path', bitmap_path);
        
        pictures(index) = add(picture, 'bitmap', current_bitmap);
        
        index = index +1;
   end;
  

    
    if (index == max_bitmap+1)
        break
    end;
end;
fprintf('Done loading pictures...\n');