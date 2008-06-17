# Read an srtm data file and turn it into an csv file

from osgeo import gdal, gdal_array
import sys
import re
from math import sqrt

# Main functions

def loadTile(filename):
  srtm = gdal.Open('data/Australia/' + filename + '.hgt')
  return gdal_array.DatasetReadAsArray(srtm)

def posFromLatLon(lat,lon):
  return (lat * 360 + lon) * 1200 * 1200

def writeTileCsvFile(tile, lat0, lon0):
  # Calculate begin position
  begin = posFromLatLon(lat0,lon0)

  # First we write the data into a temporary file.
  f = open('tile.csv', 'w')
  # We drop the top row and right column.
  for row in range(1, len(tile)):
    for col in range(0, len(tile) - 1):
      f.write(str(\
      begin + (row-1) * 1200 + col\
      ) + ", " + str(tile[row][col] ) + "\n")

  f.close() 

def getLatLonFromFileName(name):
  # Split up in lat and lon:
  p = re.compile('[NSEW]\d*')
  [lat_str, lon_str] = p.findall(name)

  # North or south?
  if lat_str[0] == "N":
    lat = int(lat_str[1:])
  else: 
    lat = -int(lat_str[1:])
  
  # East or west?
  if lon_str[0] == "E":
    lon = int(lon_str[1:])
  else: 
    lon = -int(lon_str[1:])

  return [lat,lon]

if __name__ == '__main__':
  name = sys.argv[1]
  tile = loadTile(name)
  [lat,lon] = getLatLonFromFileName(name)
  writeTileCsvFile(tile, lat, lon)
