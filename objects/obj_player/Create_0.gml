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

// Variaveis de estado
estado = noone

#endregion


#region player funções

pega_input = function()
{
    right = keyboard_check(ord("D")) or keyboard_check(vk_right)
    left = keyboard_check(ord("A")) or keyboard_check(vk_left)
    jump = keyboard_check_pressed(vk_space)
}

// pegando o input do jogador
aplica_velocidade = function()
{
    //checando se estou no chao
    checa_chao()
    
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
        
        // arredonda o y pra nao entrar no chao
        y = round(y)
        
        //Se eu apertei espaço eu pulo
        if(jump == 1)
        {
            velv = -max_velv
        }
    }
    
    //move_and_collide(velh, 0, obj_parede, 4)
    //move_and_collide(0, velv, obj_parede, 12)
}

ajusta_escala = function()
{
    if(velh != 0)
        image_xscale = sign(velh)
}

// aplicando a velocidade
movimento = function()
{
    move_and_collide(velh, 0, obj_parede, 4)
    move_and_collide(0, velv, obj_parede, 12)
}

checa_chao = function ()
{
    // Pega se o player toca no chao
    chao = place_meeting(x,y + 1, obj_parede)
}

// checa se a animaçao acabou para trocar para outra
acabou_animacao = function()
{
    var _spd = sprite_get_speed(sprite_index) / FPS
    if(image_index + _spd >= image_number)
    {
        return true
    }
}

// Metodos dos estados
troca_sprit = function(_spr = spr_parede)
{
    // verificando se ele ainda esta com o spr passado pra roda uma unica vez
    if(sprite_index != _spr)
    {
        sprite_index = _spr
        // começar animaçao do 0
        image_index = 0
    }
}

cria_particula_pulo = function (_spr = spr_pulo_particula)
{
    var _particula = instance_create_depth(x,y,depth + 1, obj_pulo_particula)
    _particula.sprite_index = _spr
}

estado_parado = function()
{
    velv = 0
    velh = 0
    aplica_velocidade()
    
    troca_sprit(spr_player_idle)
    
    // Se apertei pa direita ou esquerda muda o estado para movendo    
    if(right xor left)
    {
        estado = estado_movendo
    }
    
    if(jump)
    {
        estado = estado_pulo
        cria_particula_pulo(spr_pulo_particula)
    }
    
    // se nao estou no chao to caindo 
    if(!chao)
    {
        estado = estado_pulo
    }
}
estado_movendo = function()
{
    aplica_velocidade()
    
    troca_sprit(spr_player_move)
    
    // se a velh for 0 muda o estado para parado    
    if(velh == 0)
    {
        estado = estado_parado
    }
    
    if(jump)
    {
        estado = estado_pulo
        cria_particula_pulo(spr_pulo_particula)
    }
}
estado_pulo = function()
{
    aplica_velocidade()
    
    // se estou subindo minha velv e negativa
    if(velv < 0)
    {
        troca_sprit(spr_player_pulo)
    }
    // estou caindo minha velv e poitiva
    else
    {
        troca_sprit(spr_player_pulo_queda)
    }
    
    // estou no chao estado e parado
    if(chao)
    {
        estado = estado_parado
        cria_particula_pulo(spr_pousar_particula)
    }
}

estado_powerup_inicio = function()
{
    velh = 0
    troca_sprit(spr_player_powerup_inicio)
    
    if(acabou_animacao())
    {
        estado = estado_powerup_meio
    }
}

estado_powerup_meio = function()
{
    troca_sprit(spr_player_powerup_meio)
    
    if(acabou_animacao())
    {
        estado = estado_powerup_fim
    }
}

estado_powerup_fim = function()
{
    troca_sprit(spr_player_powerup_fim)
    
    if(acabou_animacao())
    {
        estado = estado_parado
    }
}

estado_entrando_tinta = function()
{
    troca_sprit(spr_player_tinta_entrar)
}

estado_saindo_tinta = function()
{
    troca_sprit(spr_player_tinta_sair)
    
    if(acabou_animacao())
    {
        estado = estado_parado
    }
}

#endregion

#region  debug

view_player = noone

roda_debug = function ()
{
    if(!global.debug) return
        
    show_debug_overlay(global.debug)
    
    // criando a view do debug
    view_player = dbg_view("View player", 1, 40, 100, 300, 400)

    // exibindo a velv
    dbg_watch(ref_create(id, "velv"), "velv")
       
    // slider de velv e grav
    dbg_slider(ref_create(id, "max_velv"), 0, 10, "Max velv", .1)
    dbg_slider(ref_create(id, "grav"),0 ,1, "Grav", .001)
    
    //draw_text(x, y -30, velv)
}

ativa_debug = function()
{
    if(!DEBUG_MODE) return
    
    if(keyboard_check_pressed(vk_tab))
    {
        global.debug = !global.debug
        
        // se debug for true roda o debug
        if(global.debug)
        {
            roda_debug()
        }
        else
        {
            // Desativo o debug overlay
            show_debug_overlay(0)
            // se debug for false e existir o view player deleta para nao rodar varias vezes
            if(dbg_view_exists(view_player))
            { 
                dbg_view_delete(view_player)
            }   
        }
    }
}

#endregion


// Definindo o esstado inicial do player
estado = estado_saindo_tinta