function[pictures] = load_bitmaps ( bitmap_path )
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
%  06/12/2006    Created
%  20/12/2006    Assignin base so no reloading every time is necessary

% try 
%     pictures = evalin('base', 'bitmaps');
%     if (class(pictures) == 'bitmap')
%        fprintf('Using images which are currently available in working memory\n');
%        return;
%     else
%         fprintf('Found bitmaps in working memory, but unknown type');
%     end;
% catch    
%         fprintf('No images currently available in working memory\n');
% end;

%resizeTo = [];
%resizeTo = [300 300];
resizeTo = 1;

%bitmap_path = '/Users/justvanes/Documents/JanBernard/SaliencyExperiment/stimuli/';
if nargin == 0
    bitmap_path =  '/Users/justvanes/Desktop/buildings/';
end;
    files = dir(bitmap_path);

    

fprintf('Loading image database from:\n');
bitmap_path
fprintf('One moment please...\n');

    
max_bitmap = 30;
index = 1;
pictures = bitmap;

for f = 1:size(files, 1)
     if isImage( [bitmap_path files(f).name])
        fprintf('reading file : %s\n', files(f).name);
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
        
        pictures(index) = current_bitmap;
        
        index = index +1;
   end;
  

    
    if (index == max_bitmap+1)
        break
    end;
end;
assignin('base', 'bitmaps',pictures);

fprintf('Done loading pictures...\n');
