import 'package:finanse_tracker/data/1.dart';

List<Money> geter(){
  Money upwork=Money();
  upwork.name='upwork';
  upwork.fee='50';
  upwork.time='toda';
  upwork.image='upwork.png';
  upwork.buy=false;
  Money starbucks=Money();
  starbucks.buy=true;
  starbucks.fee='20';
  starbucks.image='starbucks.png';
  starbucks.name='starbucks';
  starbucks.time='today';
  Money trasfer=Money();
  trasfer.buy=true;
  trasfer.fee='100';
  trasfer.image='crrdt.png';
  trasfer.name='transfer for sam';
  trasfer.time='Jan 30,2022';
  return[upwork,starbucks,trasfer,upwork,starbucks,trasfer];
  
}