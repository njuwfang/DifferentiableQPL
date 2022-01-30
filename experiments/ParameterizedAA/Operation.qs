namespace Gradient {
  open Microsoft.Quantum.Canon;
  open Microsoft.Quantum.Intrinsic;
  open Microsoft.Quantum.Math;
  open Microsoft.Quantum.Convert;
  open Microsoft.Quantum.Measurement;
  open Microsoft.Quantum.Arrays;

  operation qprog(PARAMETERS: Double[]): (Result[], Double[]) {
    let t = PARAMETERS[0];
    let a = PARAMETERS[1];
    let n = PARAMETERS[2];
    use qubits = Qubit[2] {
      let q = qubits[0];
      let r = qubits[1];
      mutable c = 0.;
      if (M(q) == One) { X(q);}
      if (M(r) == One) { X(r);}
      Ry(a, q);
      repeat {}
      until (not (M(r) == Zero))
      fixup {
        Z(q);
        Ry(-a, q);
        Z(q);
        Ry(a, q);
        Controlled Ry([q], (t, r));
        if ((c <= n)) {
          set c += 1.;
        } else {
          
        }
      }
      let all_result = MultiM(qubits);
      ResetAll(qubits);
      let all_count = [c];
      return (all_result, all_count);
    }
  }
  
  operation sample_qprog(SAMPLE_NUM: Int, PARAMETERS: Double[], OBSERVABLE: Double[]): Double {
    mutable sum = 0.;
    for j in 1..SAMPLE_NUM {
      let (temp, c) = qprog(PARAMETERS);
      set sum += c[0] * OBSERVABLE[ResultArrayAsInt(temp)];
    }
    return sum / IntAsDouble(SAMPLE_NUM);
  }
  
  operation sample2_qprog(SAMPLE_NUM: Int, PARAMETERS: Double[], OBSERVABLE: Double[]): Double {
    mutable sum = 0.;
    for j in 1..SAMPLE_NUM {
      let (temp, c) = qprog(PARAMETERS);
      set sum += c[0] * c[0] * OBSERVABLE[ResultArrayAsInt(temp)];
    }
    return sum / IntAsDouble(SAMPLE_NUM);
  }

  operation pdqprog_t(PARAMETERS: Double[]): (Result[], Double[], Double) {
    let t = PARAMETERS[0];
    let a = PARAMETERS[1];
    let n = PARAMETERS[2];
    use qubits = Qubit[4] {
      let q = qubits[0];
      let r = qubits[1];
      let t_q1 = qubits[2];
      let t_q2 = qubits[3];
      mutable c = 0.;
      if (M(t_q1) == One) { X(t_q1);}
      if (M(t_q2) == One) { X(t_q2);}
      mutable t_flag = 1.;
      mutable t_c = 1.;
      mutable t_ps = 0.;
      let t_s = 2.488516;
      let t_m = 0.250000;
      mutable t_a = 2. * ArcSin(Sqrt(1. / (t_s - t_ps) / t_c / PowD(Log(t_c+E()), 1.+t_m)));
      Ry(t_a, t_q2);
      if (M(q) == One) { X(q);}
      if (M(r) == One) { X(r);}
      Ry(a, q);
      repeat {}
      until (not (M(r) == Zero))
      fixup {
        Z(q);
        Ry(-a, q);
        Z(q);
        Ry(a, q);
        if (M(t_q1) == Zero) {
          if (M(t_q2) == Zero) {
            set t_ps += 1. / t_c / PowD(Log(t_c+E()), 1.+t_m);
            set t_c += 1.;
            set t_a = 2. * ArcSin(Sqrt(1. / (t_s - t_ps) / t_c / PowD(Log(t_c+E()), 1.+t_m)));
            Ry(t_a, t_q2);
          } else {
            X(t_q1);
            H(t_q2);
            if (M(t_q2) == Zero) {
              H(t_q2);
              if (M(t_q2) == Zero) { Controlled Ry([q], (PI() / 2., r)); set t_flag = 2.;}
              else { Controlled Ry([q], (-PI() / 2., r)); set t_flag = -2.;}
            } else {
              H(t_q2);
              if (M(t_q2) == Zero) { Controlled Ry([q], (PI(), r)); set t_flag = 1.0-1.0*Sqrt(2.);}
              else { Controlled Ry([q], (-PI(), r)); set t_flag = 1.0*Sqrt(2.)-1.0;}
            }
          }
        }
        Controlled Ry([q], (t, r));
        if ((c <= n)) {
          set c += 1.;
        } else {
          
        }
      }
      let result_t_q1 = M(t_q1);
      let all_result = MultiM(qubits[...1]);
      ResetAll(qubits);
      let all_count = [c];
      if (result_t_q1 == One) {
        return (all_result, all_count, t_flag * t_c * PowD(Log(t_c+E()), 1.+t_m) * t_s);
      } else {
        return (all_result, all_count, 0.);
      }
    }
  }
  
  operation sample_pdqprog_t(SAMPLE_NUM: Int, PARAMETERS: Double[], OBSERVABLE: Double[]): Double {
    mutable sum = 0.;
    for j in 1..SAMPLE_NUM {
      let (temp, c, frac) = pdqprog_t(PARAMETERS);
      set sum += c[0] * frac * OBSERVABLE[ResultArrayAsInt(temp)];
    }
    return sum / IntAsDouble(SAMPLE_NUM);
  }

  operation gradient_qprog(SAMPLE_NUM: Int, PARAMETERS: Double[], OBSERVABLE: Double[]): Double[] {
    mutable g = new Double[3];
    set g w/= 0 <- sample_pdqprog_t(SAMPLE_NUM, PARAMETERS, OBSERVABLE);
    for j in 1..2 {
      set g w/= j <- 0.;
    }
    return g;
  }
}
