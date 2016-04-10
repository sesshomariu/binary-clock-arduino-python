require 'rubygems'
require 'serialport'
ser_timeout = 0.005
time = Time.new
ser = SerialPort.new("/dev/ttyUSB0", 9600)
sleep(1.5)

#PIN DECLARATION
am = "2"
pm = "3"
h1 = "22"
h2 = "24"
h4 = "26"
h8 = "28"
s32= "30"
s16= "32"
s8 = "34"
s4 = "36"
s2 = "38"
s1 = "40"
cp = "42"

#Block that returns the hour in a 12 hour format
h12 = lambda do
  time = Time.new
  th = time.hour
  if th >= 12
    th -= 12
  end
  return th
end

#Block that returns AM or PM
am_pm = lambda do
  time = Time.new
  if time.hour >= 12
    return "PM";
  elsif time.hour < 12
    return "AM"
  end
end

#DISPLAY METHOD
show_t = lambda do
  time = Time.new
  #ap_set_before = false
  ser.write("99")
  sleep(ser_timeout + 0.005)
 
  #HOUR
  
  th12_bin = ('%04b' % h12.call).to_s
  puts "th12_bin = " << th12_bin
  charnum = 1
  th12_bin.split("").each do |i|
    if i == "1"
      if charnum == 1
        ser.write(h8)
        sleep(ser_timeout + 0.005)
      elsif charnum == 2
        ser.write(h4)
        sleep(ser_timeout + 0.005)
      elsif charnum == 3
        ser.write(h2)
        sleep(ser_timeout + 0.005)
      elsif charnum == 4
        ser.write(h1)
        sleep(ser_timeout + 0.005)
      end
    end
    charnum += 1
  end
  sleep(ser_timeout + 0.005)
  
  #AM/PM
  
  puts am_pm.call
  if am_pm.call == "AM"
    ser.write(am)
    sleep(ser_timeout + 0.005)
  elsif am_pm.call == "PM"
    ser.write(pm)
    sleep(ser_timeout + 0.005)
  end
  
  #MINUTE
  
  m_b = ('%06b' % time.min).to_s
  puts "m_b = " << m_b
  charnum = 1
  m_b.split("").each do |i|
    if i == "1"
      if charnum == 1
        ser.write(s32)
        sleep(ser_timeout + 0.005)
      elsif charnum == 2
        ser.write(s16)
        sleep(ser_timeout + 0.005)
      elsif charnum == 3
        ser.write(s8)
        sleep(ser_timeout + 0.005)
      elsif charnum == 4
        ser.write(s4)
        sleep(ser_timeout + 0.005)
      elsif charnum == 5
        ser.write(s2)
        sleep(ser_timeout + 0.005)
      elsif charnum == 6
        ser.write(s1)
        sleep(ser_timeout + 0.005)
      end
    end
    charnum += 1
  end
  
end

#Block that stores values in variables to compare them later
stovars = lambda do
  time = Time.new
  $prev_th12_bin = ('%04b' % h12.call).to_s
  $prev_m_b = ('%06b' % time.min).to_s
end

#MAIN LOOP

time = Time.new
$prev_th12_bin = ('%04b' % h12.call).to_s
$prev_m_b = ('%06b' % time.min).to_s
show_t.call
while true do
  ser.write(cp)
  sleep(ser_timeout + 0.005)
  time = Time.new
  if ('%04b' % h12.call).to_s != $prev_th12_bin || ('%06b' % time.min).to_s != $prev_m_b
    show_t.call
    stovars.call
  end
  sleep(0.1)
end
