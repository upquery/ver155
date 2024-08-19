const gulp       = require('gulp');
const { watch }   = require('gulp'); 
//minify js
const minify     = require('gulp-minify');
const rename     = require('gulp-rename');
//minify para css
const uglifycss  = require('gulp-uglifycss');
//minify para sql
const prettyData = require('gulp-pretty-data');
const exec       = require('gulp-exec');
//file system
const fs         = require('fs');



var js_file    = 'default.js';
var css_file   = 'default.css';
var sql_file   = 'fcl.sql';

const watcher_js  = watch(js_file);
const watcher_css = watch(css_file);
const watcher_sql = watch(sql_file);


gulp.task('default', (done) => { 
     
     watcher_js.on('change', function(path, stats) {
          //minify de js
          if(fs.existsSync(js_file)){
               try {
                    gulp.src(js_file).pipe(minify({
                         noSource: true
                    })).pipe(gulp.dest('./'));
               } catch(err){
                 console.log(err);
               }
          }

          console.log(`Arquivo ${path} was changed`);
     });

     watcher_css.on('change', function(path, stats) {
          //minify de css
          if(fs.existsSync(css_file)){
               gulp.src(css_file).pipe(uglifycss()).pipe(rename('default-min.css')).pipe(gulp.dest('./'));
          }  

          console.log(`File ${path} was changed`);
     });

     watcher_sql.on('change', function(path, stats) {
          //run bat
          if(fs.existsSync(sql_file)){
               exec('wrap_fcl.bat');
          }  

          console.log(`File ${path} was changed`);
     });

     done();	
});