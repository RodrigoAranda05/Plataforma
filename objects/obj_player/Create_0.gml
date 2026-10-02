#region variaveis
velh = 0
max_velh = 1
velv = 0
max_velv = 4
grav = 0.2

chao = false

//Variaveis de input
right = false
left = false
jump = false

#endregion


#region player funções

pega_input = function()
{
    right = keyboard_check(ord("D")) or keyboard_check(vk_right)
    left = keyboard_check(ord("A")) or keyboard_check(vk_left)
    jump = keyboard_check(vk_space)
}

movimento = function()
{
    velh = (right - left) * max_velh
    
    //Aplicando a gravidade
    //Se eu estou tocando no chao eu aplico a gravidade a minha velv
    if(!chao)
    {
        velv += grav
    }
    // Caso ao contrario eu zero meu velv
    else // estou no chao
    {
        velv = 0
        
        //Se eu apertei espaço eu pulo
        if(jump == 1)
        {
            velv = -max_velv
        }
    }
    
    move_and_collide(velh, 0, obj_parede, 4)
    
    move_and_collide(0, velv, obj_parede, 12)
}

checa_chao = function ()
{
    // Pega se o player toca no chao
    chao = place_meeting(x,y + 1, obj_parede)
}

#endregion