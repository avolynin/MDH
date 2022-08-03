extends Object

class_name ForwardKinematic

var theta_array
var a_array
var d_array
var alpha_array

func calculate(thetaArray, joints := 6):
	theta_array = thetaArray
	var matrix = forwardTransform(joints)
	return matrix

func _init(aArray, dArray, alphaArray):
	a_array = aArray
	d_array = dArray
	alpha_array = alphaArray

func prevMatTransform(i):
	var result = []
	for y in range(4):
		var tmp = []
		for x in range(4):
			tmp.append(0)
		result.append(tmp)
	
	result[0][0] = cos(theta_array[i]);
	result[0][1] = -cos(alpha_array[i]) * sin(theta_array[i]);
	result[0][2] = sin(alpha_array[i]) * sin(theta_array[i]);
	result[0][3] = a_array[i] * cos(theta_array[i]);

	result[1][0] = sin(theta_array[i]);
	result[1][1] = cos(alpha_array[i]) * cos(theta_array[i]);
	result[1][2] = -sin(alpha_array[i]) * cos(theta_array[i]);
	result[1][3] = a_array[i] * sin(theta_array[i]);

	result[2][0] = 0;
	result[2][1] = sin(alpha_array[i]);
	result[2][2] = cos(alpha_array[i]);
	result[2][3] = d_array[i];

	result[3][0] = 0;
	result[3][1] = 0;
	result[3][2] = 0;
	result[3][3] = 1;

	return result;
func forwardTransform(joints):
	var transformMatrix = prevMatTransform(0);
	for i in range(1, joints):
		transformMatrix = multMat(transformMatrix,prevMatTransform(i))
	return transformMatrix;

func multMat(m1, m2):
	var s=0     #сумма
	var t=[]    #временная матрица
	var m3=[] # конечная матрица
	if len(m2)!=len(m1[0]):
		pass     
	else:
		var r1=len(m1) #количество строк в первой матрице
		var c1=len(m1[0]) #Количество столбцов в 1   
		var r2=c1           #и строк во 2ой матрице
		var c2=len(m2[0])  # количество столбцов во 2ой матрице
		for z in range(0,r1):
			for j in range(0,c2):
				for i in range(0,c1):
					s=s+m1[z][i]*m2[i][j]
				t.append(s)
				s=0
			m3.append(t)
			t=[]           
	return m3
