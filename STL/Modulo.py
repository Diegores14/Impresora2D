import numpy
from stl import mesh
#import matplotlib.pyplot as plt
import math
import time
import serial
import binascii

def Info(meshh):

	#Acceso a todos los triangulos 
	#print( Mymesh.vectors)
	NumTringulos = '{} {} '.format(len(meshh.vectors) , 'triangulos')
	print(NumTringulos)
	print('{} {} '.format( len(meshh.vectors[0]), 'puntos X Y Z por triangulo'))

def f(meshh, contenedor):
	"""  Permite leer el archivo y obener puntos X,Y cuando Z = 0 """
	for triangulo in meshh.vectors:
		for punto1 in triangulo:

			k = int(punto1[2])
			#encontramos que el punto es igual a 0
			if k  ==  0 :
				contenedor.append([int(punto1[0]), int(punto1[1])])
	
	#elmino los elementos repetidos
	contenedor2 = []
	for punto in contenedor:
		if punto not in contenedor2:
			contenedor2.append(punto)
	
	return contenedor2


def Graficador(Puntos):
	x = []
	y = []

	for punto in Puntos:
		x.append(punto[0])
		y.append(punto[1])

	plt.plot(x,y)
	plt.show()	

#def ordenarPuntosDistancia
#lista.index(elemento) me entrega la pos de ese elemento en la lista
#lista.pop(num) eliminna un elemento de una pos especifica en una lista 

def Distance(punto1, punto2):
	d = math.sqrt( (punto1[0] - punto2[0])**2 + (punto1[1] - punto2[1])**2)
	return d

def OrdenarPuntos(Puntos):
	newOrden = [Puntos.pop(0)]
	#print(newOrden)
	NextPos = 0 
	while(len(Puntos)):
		last = len(newOrden) - 1
		distance = 1000000000.
		for punto in Puntos:
			#print(newOrden[last], punto)
			d = Distance(newOrden[last], punto)
			if d < distance: #Nueva distancia menor
				distance = d
				NextPos = Puntos.index(punto)
		newOrden.append(Puntos.pop(NextPos))
	print(len(Puntos))

	return newOrden

#--------------------------------------------------------------------------------------------------
#Generacion de puntos intermedios

def Pendiente(puntoA, puntoB):
	''' Cacula la pendiente que habria entre dos puntos'''
	m = (puntoB[0] - puntoA[0]) / (puntoB[1] - puntoA[1])
	return m

def CalcY(puntoA, m , x):
	''' Despejo la ecuacion de la recta 
		Y -Yo = m(X -Xo)
		para con un X determinado hallar un Y '''
	Y = m * (x - puntoA[0]) + puntoA[1]
	return int(Y)


def PuntosMedios(puntoA, puntoB):
	'''Calcula en un arreglo de puntos intermedios entre dos puntos'''
	Medios = []
	m = Pendiente(puntoA,puntoB)#calculo la pendiente
	for X in range(puntoA[0], puntoB[0]):#recojo el eje X  encontrando cada Y correspondiente y insertando los puntos en medios
		Y = CalcY(puntoA,m, X)
		Medios.append([X,Y])

	return Medios
'''
def DefinirLineas(Puntos):
	#alcular entre cada linea, todos sus puntos intermedios

	Nuevo = []
	Medios = []
	while(len(Puntos)):
		A = 0
		B = 0
		if(len(Puntos) == 1):
			A = Nuevo.pop()
			B = Puntos.pop(0)
			if B[1] - A[1] == 0:
				Medios = []
			else:
				Medios = PuntosMedios(A,B)

		else:
			A = Puntos.pop(0)
			B = Puntos.pop(0)
			if B[1] - A[1] == 0:
				Medios = []
			else:
				Medios = PuntosMedios(A,B)

		Nuevo.append(A)
		Nuevo.extend(Medios)
		Nuevo.append(B)
	return Nuevo '''


#---------------------------------------------------------------------------------
#funciones de la conexion serial

def Send(ser, Puntos):
	x2 = 0
	y2 = 0
	for punto in Puntos:
		mov = 0
		if x2-punto[0] != 0:
			m = float(y2-punto[1])/float(x2-punto[0])     # calcula la pendiente
			for x in range(abs(punto[0]-x2)):             # genera la recta y calcula el numero de pasos
				if punto[0]-x2 < 0:
					ser.write(bytearray(str(5),'utf8'))   # se mueve hacia la izquiera 
				else:
					ser.write(bytearray(str(4),'utf8'))   # se mueve hacia la derecha
				y = abs(m*(x+1))                          # aplico la ecuacion de la recta
				Send2(ser, int(mov - y), punto[1]-y2)
				mov = int(y)
		if x2-punto[0] == 0:
			Send2(ser, punto[1]-y2, punto[1]-y2)
		x2 = punto[0]
		y2 = punto[1]
	ser.write(bytearray(str(6),'utf8'))
	ser.write(bytearray(str(1),'utf8'))


# envia el numero de pasos en el eje vertical
def Send2(ser,pasos, pendiente):
	if pendiente<0 :
		for i in range(abs(pasos)):
			ser.write(bytearray(str(3),'utf8'))
	if pendiente > 0 :
		for i in range(abs(pasos)):
			ser.write(bytearray(str(2),'utf8'))
	
if __name__ == '__main__':

	Mymesh = mesh.Mesh.from_file('MickeyCookieCutterRiaan.stl')
	Info(Mymesh)
	Puntos = []

	#elimino los puntos repetidos y obtengo el eje 0
	Puntos = f(Mymesh, Puntos)
	print(len(Puntos))	 	
	#print(Puntos)print(Distance(Puntos[0],Puntos[0]))
	Puntos = OrdenarPuntos(Puntos)
	#Graficador(Puntos)

	#defino el puerto
	ser = serial.Serial(
		port='COM1',
		baudrate=9600,
		parity=serial.PARITY_ODD,
		stopbits=serial.STOPBITS_TWO,
		bytesize=serial.EIGHTBITS
	)

	ser.isOpen()
	Send(ser, Puntos)
	ser.close()


	
#LINKS
#http://numpy-stl.readthedocs.io/en/latest/
#https://github.com/pyserial/



