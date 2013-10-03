function genpdp(output_file, label_file, PCA_L, PCA_R)
outsize = 30;

labels = readfile(label_file);

fid = fopen(output_file, 'w');
pid = 0;
lastperson = '';

for i = 1:size(PCA_L, 1)
    fprintf(fid, '# startgroup\n');
    [label rest]=strtok(labels{i}, '.');
    [person face] = strtok(label, '_');
    if strcmp(lastperson, person) == 0
        lastperson = person;
        pid = pid + 1;
    end

    fprintf(fid, '%s ', label);
    fprintf(fid, '%g ', PCA_L(i,:));
    fprintf(fid, '%g ', PCA_R(i,:));
    fprintf(fid, '%d ', zeros(1, outsize));
    fprintf(fid, '\n');
    out = zeros(1, 30); out(pid) = 1;
    fprintf(fid, '%s ', label);
    fprintf(fid, '%g ', PCA_L(i,:));
    fprintf(fid, '%g ', PCA_R(i,:));
    fprintf(fid, '%d ', out);
    fprintf(fid, '\n');
end

fclose(fid);