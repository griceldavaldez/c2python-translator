def imprimirMensaje():
	print("¡Llamada a procedimiento!\n")
	
def pow2(n, m):
	i = 1
	res = 1
	while (i<=m):
		res = res*n
		i+=1
		
	print("res = %d" % (res))
	return res
	
def main():
	
	x = pow2(4, 3)
	return 0
	imprimirMensaje()
	
if __name__ == '__main__':
	main()
