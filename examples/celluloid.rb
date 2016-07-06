require 'timeout/extensions/celluloid'                   
                                      
module MyJob                           
  def self.perform                         
    puts "performing"                 
    sleep 5                           
    puts "performed!"                 
  end                                 
end                                   
                                      
class Worker                          
  include Celluloid                   
                                      
  def develop                         
    MyJob.perform                     
  end                                 
                                      
  def ten_times_developer             
    10.times.each { async(:develop) } 
  end                                 
end                                   
                                      
Worker.new.async(:ten_times_developer)
                                      
sleep                                 
