def main():
				
	vector = [3, 4, 12, 1, 9]
	n = 5
	posMayor = 0
	mayor = vector[0]
	for i in range(1,n):		
		if(vector[i]>mayor):
			mayor = vector[i]
			posMayor = i
			
		
	print("El numero mayor fue: %d (indice: %d)\n" % (mayor,posMayor))
	return 0
	
if __name__ == '__main__':
	main()
